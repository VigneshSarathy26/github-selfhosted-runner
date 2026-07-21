# AKS GitHub Runners: `job-containers/` Pattern vs. `docker-dind`

## The core distinction

There are two different places Python/Node/Terraform can live:

1. **The runner pod itself** (`images/runner-python`, etc.) — this is the machine that picks up the job from GitHub and executes the workflow's steps.
2. **A container the job runs inside**, via the `container:` key in the workflow YAML — the runner pod stays generic, and just launches your job's steps inside *this* container instead of directly on itself.

```yaml
jobs:
  build:
    runs-on: [self-hosted, generic]     # <- runner pod (dumb, minimal)
    container:
      image: ghcr.io/yourorg/build-python312:latest   # <- job-containers/build-python312
    steps:
      - run: python --version   # actually runs inside build-python312, not on the runner pod
```

`job-containers/*` are the Dockerfiles for option 2.

## Why maintain both instead of just one?

**Without `job-containers/`**, your only way to give a job "Python 3.12 + specific libs" is to build a whole dedicated **runner scale set** for it — a new ARC `RunnerScaleSet`, a new Helm values file, a new label, a new pool of pods sitting around in AKS waiting for work.

That's a lot of infrastructure overhead for something that might just be:
- a one-off toolchain used by 1 repo
- a version combo needed for a single job step
- something that changes often (e.g., you bump Python patch versions monthly)

**With `job-containers/`**, you keep a small number of generic runner pools (`runner-generic`, maybe `runner-docker-dind`), and let individual jobs pull in whatever exact environment they need at *job execution time*, just by referencing an image — no new scale set, no new Helm deploy, no new AKS pods to provision and keep warm.

## Concretely, when to use which

| Situation | Use |
|---|---|
| Toolchain is used by **many repos/jobs**, stable, heavily used | Dedicated `images/runner-*` scale set (worth the standing infra) |
| Toolchain is used by **one repo**, or changes often, or is a minor variant (3.12.1 vs 3.12.3) | `job-containers/*` + `container:` key — no new scale set needed |
| You want the **runner pool itself minimal** to avoid maintaining N scale sets | Push specificity down into `job-containers/*`, keep `runner-generic` doing the scheduling |
| Job needs Docker-in-Docker / privileged access | Must be a `runs-on` runner image (`runner-docker-dind`), *not* a job container — nested container execution needs the pod itself configured for it |

## The practical payoff

Without this split, every new version bump or new toolchain = a new runner scale set = more AKS pods idling, more ARC config, more Helm values files to maintain, slower to add. This is the actual fix for image bloat and proliferation: `job-containers/` lets you handle the "many different toolchains" problem **without multiplying runner pools**, keeping your AKS footprint to just a couple of generic pools plus a growing but cheap set of job container images (which only get pulled when actually used, not kept running).

**Trade-off:** slight latency per job for the image pull (mitigated by registry caching / keeping job-container images small), and DinD/privileged jobs can't use this pattern — those need to be actual runner images.

---

## The mental model

```
AKS Node
 └── Runner Pod (runner-generic image)
      │  This pod's ONLY job: register with GitHub, wait for a job,
      │  and launch the "container:" image as a sibling container
      │  to actually execute the steps
      │
      └── Job Container (build-python312 image)
           │  This is where `pip install`, `pytest`, etc. actually run
           └── Your repo checked out here, steps executed here
```

The runner pod is basically a **dumb executor/scheduler**. The `container:` image is where the real work and real toolchain live. This is exactly how GitHub-hosted runners work too — `ubuntu-latest` is generic, and any job with a `container:` key runs its steps inside that image instead.

## Full example: `job-containers/build-python312/Dockerfile`

```dockerfile
FROM python:3.12-slim

# Only what's needed to build/test — not the runner agent, not git, not docker
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir poetry pytest

WORKDIR /workspace
```

Notice: **no GitHub Actions runner binary in here at all.** That's the key difference from `images/runner-python`. This image doesn't need to know how to talk to GitHub — the runner pod handles that. This image just needs the language toolchain.

## The generic runner pod: `images/runner-generic/Dockerfile`

```dockerfile
FROM ghcr.io/yourorg/runner-base:latest
# nothing extra — no python, no node, no terraform
# just the runner agent + git + docker CLI (inherited from base)
```

This single image now serves **every job**, regardless of language — because the actual language runtime is injected per-job via `container:`.

## ARC Helm values: `helm/arc-runner-sets/values-generic.yaml`

```yaml
githubConfigUrl: "https://github.com/yourorg"
githubConfigSecret: gha-runner-secret
runnerScaleSetName: generic

template:
  spec:
    containers:
      - name: runner
        image: ghcr.io/yourorg/runner-generic:latest
        command: ["/home/runner/run.sh"]
```

One scale set. That's it. You don't need `runner-python311-scaleset`, `runner-python312-scaleset`, `runner-node20-scaleset`, etc.

## The workflow files — this is where it comes together

```yaml
# repository1a/.github/workflows/build.yml
name: Build repo1a (Python 3.12)

on: [push]

jobs:
  build:
    runs-on: [self-hosted, generic]        # <- lands on runner-generic pod
    container:
      image: ghcr.io/yourorg/build-python312:latest   # <- steps run inside THIS
    steps:
      - uses: actions/checkout@v4
      - run: python --version                # -> Python 3.12.x
      - run: poetry install
      - run: pytest
```

```yaml
# repository2a/.github/workflows/build.yml
name: Build repo2a (Node 20)

on: [push]

jobs:
  build:
    runs-on: [self-hosted, generic]        # <- SAME pool, same label
    container:
      image: ghcr.io/yourorg/build-node20:latest      # <- different job container
    steps:
      - uses: actions/checkout@v4
      - run: node --version                   # -> Node 20.x
      - run: npm ci
      - run: npm test
```

Both jobs use `runs-on: [self-hosted, generic]` — same pool, same pods, same ARC scale set. But they get completely different toolchains because the **job container**, not the runner, defines the environment. This scales the number of *lightweight job-container images* (cheap, pulled on demand) instead of the number of *runner scale sets* (each one is standing AKS infrastructure).

## What actually happens step by step

1. GitHub queues a job for repository1a, requesting `[self-hosted, generic]`.
2. ARC's listener sees this, scales up a pod from `runner-generic` image in AKS.
3. Pod registers with GitHub, picks up the job.
4. The runner agent inside the pod reads the `container:` key from the workflow.
5. It pulls `build-python312:latest` and starts it (using the Docker CLI/socket available in the runner pod — this is why `runner-base` needs Docker installed).
6. Your repo is checked out into a volume shared between runner pod and job container.
7. All `steps:` execute **inside `build-python312`**, not inside `runner-generic`.
8. Job finishes → job container stops → (if ephemeral) runner pod is torn down too.

## Why this needs the runner pod to have Docker/DinD-capable setup

This is the one prerequisite: your `runner-base` image needs Docker (or the pod needs privileged mode / a Docker socket mounted) because the runner agent is literally invoking `docker run` under the hood to launch your job container. That's already covered by having `docker CLI` in `base/Dockerfile` — that's why that line is there.

## When job-containers stops being the right choice

If a job needs to build/push its *own* Docker images (nested containers), plain `container:` execution can get awkward with socket permissions — that's when you'd route that specific job to the `runner-docker-dind` scale set instead (an actual dedicated runner image, not a job container), since DinD needs privileges at the pod level, not the inner container level.

---

## Why DinD is different

When a job needs to run `docker build`/`docker push` itself (not just execute *inside* a container, but *create* containers), the job needs access to a Docker daemon with real privileges. You can't safely hand that to an arbitrary `job-containers/*` image sitting inside another container — nested Docker access needs to be configured at the **pod level** (privileged mode or a mounted socket), which is an ARC/Helm-level decision, not a workflow-level one. So this has to be its own runner scale set.

## `images/runner-docker-dind/Dockerfile`

```dockerfile
FROM ghcr.io/yourorg/runner-base:latest

USER root

# Install Docker Engine (not just the CLI — DinD needs the daemon too)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg lsb-release \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
        https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
        > /etc/apt/sources.list.d/docker.list \
    && apt-get update && apt-get install -y --no-install-recommends \
        docker-ce docker-ce-cli containerd.io docker-buildx-plugin \
    && rm -rf /var/lib/apt/lists/*

RUN usermod -aG docker runner

USER runner
```

Note this is heavier than `runner-generic` on purpose — it's a small, dedicated pool that only DinD jobs use, so the bloat is contained to exactly the jobs that need it.

## `helm/arc-runner-sets/values-docker-dind.yaml`

The key difference from `values-generic.yaml`: this pod needs `privileged: true` (or a properly configured rootless DinD setup) so the Docker daemon inside it can actually create containers/networking.

```yaml
githubConfigUrl: "https://github.com/yourorg"
githubConfigSecret: gha-runner-secret
runnerScaleSetName: docker-dind

template:
  spec:
    containers:
      - name: runner
        image: ghcr.io/yourorg/runner-docker-dind:latest
        command: ["/home/runner/run.sh"]
        securityContext:
          privileged: true          # <- required for DinD; NOT set on runner-generic
        env:
          - name: DOCKER_HOST
            value: tcp://localhost:2375
      - name: dind
        image: docker:24-dind
        securityContext:
          privileged: true
        args:
          - --host=tcp://0.0.0.0:2375
          - --host=unix:///var/run/docker.sock
```

This runs the runner and a `dind` sidecar container together in the same pod, sharing the Docker daemon over `DOCKER_HOST`. This is the standard ARC sidecar pattern for DinD.

## Example workflow: building and pushing an image

```yaml
# repository3a/.github/workflows/build-and-push.yml
name: Build and push image

on: [push]

jobs:
  build:
    runs-on: [self-hosted, docker-dind]     # <- dedicated pool, NOT generic
    steps:
      - uses: actions/checkout@v4

      - name: Log in to registry
        run: echo "${{ secrets.REGISTRY_PASSWORD }}" | docker login ghcr.io -u ${{ github.actor }} --password-stdin

      - name: Build image
        run: docker build -t ghcr.io/yourorg/myapp:${{ github.sha }} .

      - name: Push image
        run: docker push ghcr.io/yourorg/myapp:${{ github.sha }}
```

Notice this job has **no `container:` key** — it runs directly on the `runner-docker-dind` pod, because it's building images itself, not just executing inside one.

## Side-by-side summary

| | `runner-generic` + `container:` | `runner-docker-dind` |
|---|---|---|
| Used for | Running build/test steps in a specific language toolchain | Building/pushing Docker images, anything needing `docker build` |
| Privilege level | Unprivileged | Privileged (or rootless DinD) |
| Where toolchain lives | `job-containers/*` image, pulled per job | Baked into the runner pod itself |
| Number of scale sets needed | 1 (shared by everything) | 1 dedicated pool, kept separate deliberately |
| Repo example | repository1a (Python), repository2a (Node) | repository3a (image builds) |

## Net result

Most jobs route through **one generic pool + job-container images** (cheap, no image bloat, easy to add new toolchains). Only the minority of jobs that genuinely need Docker-level privileges get routed to the dedicated `runner-docker-dind` pool, kept intentionally separate so privileged access isn't accidentally granted to everything else.

---

## When to add a new job container

Add a new `job-containers/*` image when:

- **A repo/job needs a toolchain or version not covered by existing images** — e.g., someone needs Go 1.22 and you don't have one yet.
- **The need is narrow** — one repo, one job, or a handful of jobs. If it's not worth standing up a whole runner pool for, it's a job-container candidate.
- **The toolchain doesn't need special pod-level privileges** — no DinD, no host networking, no privileged mode. If it just needs binaries/libraries to run `steps:`, it belongs here.
- **It changes independently of other toolchains** — e.g., you want to bump Terraform versions without touching your Python image. Splitting by job-container keeps blast radius small.
- **You want fast iteration** — since these are just images pulled per job (not standing infrastructure), you can add/update one without touching ARC/Helm config at all.

## Why add it (vs. just using `runner-generic` bare, or building a new scale set)

- **Reproducibility** — pinned tool versions per job instead of "whatever's on the shared runner."
- **No new AKS infra** — you avoid a new `RunnerScaleSet` + Helm values + idle pods for something that might be used by one pipeline.
- **Isolation between jobs** — repo A's Python 3.11 job and repo B's Python 3.12 job never fight over installed versions, even though both use the same `runner-generic` pool.
- **Keeps `runner-generic` and `runner-base` slim** — bloat lives in small, disposable, per-job images instead of accumulating on your core runner image.
- **Easy to retire** — if a toolchain stops being used, delete the Dockerfile and stop pushing it. No scale set to tear down, no idle pods to clean up.

## Other job-container examples beyond `build-python312` and `build-node20`

| Image | Use case |
|---|---|
| `build-python311` | Repos still on 3.11 (separate from 3.12, so version pinning is explicit) |
| `build-node18` | Legacy Node apps not yet migrated to 20 |
| `build-java17` / `build-java21` | Maven/Gradle builds, JDK version pinned per repo |
| `build-golang122` | Go builds, `go build`/`go test`, golangci-lint |
| `build-dotnet8` | .NET SDK builds/tests |
| `build-terraform` | `terraform plan/apply`, tflint, cloud CLI (az/aws/gcloud) — no Docker needed unless it also builds images |
| `build-ansible` | Ansible playbook runs, config management jobs |
| `build-rust` | `cargo build/test`, clippy |
| `build-android-sdk` | Android build tooling (gradle + SDK, no emulator) |
| `lint-only` | Just linters/formatters (eslint, black, shellcheck) — very small image for fast PR checks |
| `build-php81` | PHP + composer for PHP repos |
| `build-ruby32` | Ruby + bundler |
| `security-scan` | Trivy, Snyk CLI, SAST tools — used as a step container across many repos regardless of their main language |
| `build-cpp-gcc12` | C/C++ builds with a pinned GCC/CMake version |
| `build-docs` | Sphinx/MkDocs/Docusaurus for docs-only repos — tiny image, fast builds |

**Rule of thumb:** if it's "language/tool + version, no special privileges," it's a job-container. If it needs privileged access (DinD, host devices, kernel modules) or is used by *most* of your org's pipelines and rarely changes, that's when it graduates to a dedicated `images/runner-*` scale set instead.

## Example Dockerfiles

### `job-containers/build-golang122/Dockerfile`

```dockerfile
FROM golang:1.22-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

WORKDIR /workspace
```

```yaml
# example usage
jobs:
  build:
    runs-on: [self-hosted, generic]
    container:
      image: ghcr.io/yourorg/build-golang122:latest
    steps:
      - uses: actions/checkout@v4
      - run: go build ./...
      - run: go test ./...
      - run: golangci-lint run
```

### `job-containers/build-terraform/Dockerfile`

```dockerfile
FROM hashicorp/terraform:1.8

RUN apk add --no-cache curl unzip python3 py3-pip

# Azure CLI for AKS/Azure-targeted terraform runs
RUN pip3 install --no-cache-dir --break-system-packages azure-cli

RUN curl -Lo /usr/local/bin/tflint \
    https://github.com/terraform-linters/tflint/releases/latest/download/tflint_linux_amd64.zip \
    && unzip /usr/local/bin/tflint -d /usr/local/bin \
    && chmod +x /usr/local/bin/tflint

WORKDIR /workspace
```

```yaml
# example usage
jobs:
  plan:
    runs-on: [self-hosted, generic]
    container:
      image: ghcr.io/yourorg/build-terraform:latest
    steps:
      - uses: actions/checkout@v4
      - run: terraform init
      - run: tflint
      - run: terraform plan
```

### `job-containers/lint-only/Dockerfile`

```dockerfile
FROM node:20-slim

# Deliberately minimal — fast pulls for PR-gate lint checks
RUN npm install -g eslint prettier

RUN apt-get update && apt-get install -y --no-install-recommends \
    shellcheck python3-pip \
    && pip3 install --no-cache-dir --break-system-packages black \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
```

```yaml
# example usage
jobs:
  lint:
    runs-on: [self-hosted, generic]
    container:
      image: ghcr.io/yourorg/lint-only:latest
    steps:
      - uses: actions/checkout@v4
      - run: eslint .
      - run: black --check .
      - run: shellcheck scripts/*.sh
```

These follow the same pattern as `build-python312`: no runner agent, no Docker CLI, no GitHub-specific bits — just the toolchain, kept as small as the job actually needs.