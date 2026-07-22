# Custom GitHub Self-Hosted Runner Platform

[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.28%2B-blue?logo=kubernetes&logoColor=white)](https://kubernetes.io)
[![Helm](https://img.shields.io/badge/Helm-v3.0%2B-blue?logo=helm&logoColor=white)](https://helm.sh)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-Self--Hosted-orange?logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

An enterprise-grade, high-performance, and cost-optimized **Custom Helm-based Platform** for managing and scaling GitHub Actions self-hosted runners on Kubernetes (EKS, AKS, GKE). 

This platform extends the foundation of the standard **GitHub Actions Runner Controller (ARC)**, resolving core enterprise pain points with advanced auto-scaling, strict governance, robust self-healing, multi-cloud redundancy, and optimized resource utilization.

---

## 🗺️ Architectural Overview

This platform segregates concerns into a control plane running on system node pools and highly optimized, ephemeral runner fleets scheduled dynamically on application node pools.

```
                  ┌───────────────────────────────────────────────────┐
                  │                Kubernetes Cluster                 │
                  ├───────────────────────────────────────────────────┤
                  │                                                   │
                  │  ┌──────────────────┐     ┌────────────────────┐  │
                  │  │ System Node Pool │     │  Runner Node Pool  │  │
                  │  │                  │     │    (Karpenter)     │  │
                  │  │ - ARC Controller │     │                    │  │
                  │  │ - KEDA / VPA     │────>│ - Ephemeral Pods   │  │
                  │  │ - Gatekeeper     │     │ - Spot / On-Demand │  │
                  │  │ - cert-manager   │     │ - Auto-remediated  │  │
                  │  └──────────────────┘     └────────────────────┘  │
                  │                                                   │
                  └───────────────────────────────────────────────────┘
```

---

## ⚡ Key Capabilities

### 1. Predictive & Event-Driven Autoscaling
*   **KEDA Integration:** Event-driven scaling directly based on GitHub workflow queue metrics rather than resource thresholds (CPU/Memory).
*   **ML Forecasting:** Supports demand forecasting (Prophet/LSTM) and scheduled cron rules to scale up pools prior to morning surges or release windows, eliminating cold-start delays.
*   **Off-Hours Scale Down:** Integration with `kube-downscaler` automatically scales down non-essential runner groups during nights and weekends, reducing idle compute costs by up to 60%.

### 2. Spot-First Cost Optimization
*   **Karpenter Node Provisioning:** Dynamically provisions instances based on exact runner requests, using diverse instance families (`c5`, `c6i`, `m5`, `m6i`, etc.).
*   **Hybrid Pools:** Utilizes a Spot-first strategy (aiming for 70% Spot allocation) with an automatic failover fallback to On-Demand instances when Spot capacity is constrained.
*   **Graceful Termination Handling:** Captures Spot interruption notifications and drains runners gracefully (2-minute warning) to prevent interrupted workflows.

### 3. Isolated Job-Containers Pattern
*   **Anti-Bloat Design:** Separates the runner executor from the toolchains. Instead of maintaining giant, specialized runner images, you run a minimal, generic runner pod (`runner-generic`) that dynamically fetches lightweight toolchain containers (`job-containers/`) using the workflow's `container:` key.
*   **Toolchains-on-Demand:** Keeps the AKS footprint minimal while developer teams get customized runtime configurations (Python, Node.js, Go, Terraform) without multiplying dedicated infrastructure.

### 4. Enterprise Governance & Security
*   **Policy-as-Code:** Uses **OPA/Gatekeeper** and **Kyverno 2.0** to validate pod specifications, blocking privileged execution, restricting host mounts, and enforcing resource limits.
*   **Secret Management:** Native integrations for injecting secrets via external secret providers like HashiCorp Vault.
*   **Resource Management:** Employs **Vertical Pod Autoscaler (VPA)** in auto-recommender mode to fine-tune CPU/Memory limits based on historical job executions.

### 5. Auto-Healing & Resilience
*   **Health Probes:** Sidecars continuously monitor runner daemon status, disk I/O, and registration state.
*   **State Alignment:** Automatically detects if a runner becomes unresponsive (`Offline` or `Idle` state) on GitHub, unregisters it, and recreates the pod.
*   **Node Quarantine:** Cordons and drains Kubernetes nodes demonstrating high runner failure rates.

---

## 📂 Repository Structure

The codebase is organized logically to separate container images, helm configurations, infrastructure templates, and documentation:

```filepath
github-selfhosted-runner/
├── .github/workflows/          # CI/CD pipelines to build/publish runner & toolchain images
├── base/                       # Foundational Dockerfile and registration entrypoint script
│   ├── Dockerfile              # Core runner image setup (Ubuntu 24.04 + GitHub agent v2.335.1)
│   └── entrypoint.sh           # Runner registration/deregistration lifecycle scripts
├── images/                     # Specialized execution runners (with installed agents)
│   ├── runner-generic/         # Light runner acting as the orchestrator/scheduler
│   ├── runner-docker-dind/     # Privileged Docker-in-Docker runners
│   ├── runner-node/            # Node.js developer environment runner
│   ├── runner-python/          # Dedicated Python execution runner
│   └── runner-terraform/       # Terraform execution runner
├── job-containers/             # Lightweight environments (no runner agent binary)
│   ├── build-android-sdk/      # Android build tooling (Gradle + Android SDK)
│   ├── build-ansible/          # Ansible playbook runs and config management
│   ├── build-cpp-gcc12/        # C/C++ builds (GCC 12 + CMake + Ninja)
│   ├── build-docs/             # Documentation site builds (Sphinx / MkDocs / Docusaurus)
│   ├── build-dotnet8/          # .NET 8 SDK application builds and testing
│   ├── build-golang122/        # Go 1.22 builds, tests, and golangci-lint
│   ├── build-java17/           # Enterprise Java 17 LTS (Maven / Gradle)
│   ├── build-java21/           # Modern Java 21 LTS (Virtual threads, Spring Boot 3)
│   ├── build-node18/           # Legacy Node.js 18.x applications
│   ├── build-node20/           # Primary Node.js 20.x build environment
│   ├── build-php81/            # PHP 8.1 + Composer applications
│   ├── build-python311/        # Legacy Python 3.11 microservices
│   ├── build-python312/        # Primary Python 3.12 build environment
│   ├── build-ruby32/           # Ruby 3.2 + Bundler applications
│   ├── build-rust/             # Rust builds (`cargo test`, clippy)
│   ├── build-terraform/        # Terraform IaC validation & cloud CLI steps
│   ├── lint-only/              # Fast multi-language PR linting (ESLint, Black, ShellCheck)
│   └── security-scan/          # Cross-repo vulnerability SAST scanning (Trivy, Snyk)
├── helm/
│   └── custom-runner/          # Custom Helm Chart for deploying runner pools
│       ├── templates/          # K8s manifest templates (Deployments, HPA, Ingress, Services)
│       └── values.yaml         # Config options for Karpenter, KEDA, VPA, and policies
├── script/                     # Administrative utility scripts
│   ├── build-all.sh            # Builds all local images
│   ├── build-single.sh         # Builds a single runner image
│   ├── test-runner.sh          # Performs end-to-end container testing
│   └── prune-old-images.sh     # Script to clean up obsolete Docker layers
└── docs/                       # Comprehensive platform documentation and design specs
```

---

## ⚙️ Quick Start

### 1. Prerequisites
*   A running Kubernetes cluster (v1.28+) with public/private subnet topology.
*   `kubectl` and `helm` (v3+) CLI tools installed.
*   A configured **GitHub Organization App** (or Personal Access Token) with the following permissions:
    *   **Repository > Actions**: Read-only
    *   **Repository > Administration**: Read & Write
    *   **Repository > Metadata**: Read-only
    *   **Organization > Actions**: Read-only
    *   **Organization > Self-hosted Runners**: Read & Write

### 2. Configure Credentials
Create the Kubernetes secret for the controller manager using your GitHub Organization App credentials:

```bash
kubectl create secret generic controller-manager \
  -n arc-systems \
  --from-literal=github_app_id=<YOUR_APP_ID> \
  --from-literal=github_app_installation_id=<YOUR_INSTALLATION_ID> \
  --from-file=github_app_private_key=path/to/your-github-app-key.pem
```

For KEDA authentication (if using personal access token fallback):
```bash
kubectl create secret generic github-token \
  -n arc-runners \
  --from-literal=token=ghp_YOUR_PERSONAL_ACCESS_TOKEN
```

### 3. Deploy the Platform
Install the custom runner Helm chart with your organization configurations:

```bash
# Add chart repositories
helm repo add fairwinds-stable https://charts.fairwinds.com/stable
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts

# Install custom runner
helm upgrade --install custom-runner ./helm/custom-runner \
  --namespace arc-runners \
  --create-namespace \
  --set global.github.org="your-github-organization"
```

---

## 🛠️ Usage Patterns

### Pattern A: Standard Runner (Monolithic Image)
For stable workflows that run frequently and require heavy, pre-cached binaries on the host:
```yaml
jobs:
  build:
    runs-on: [self-hosted, python] # Routes directly to images/runner-python
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      - name: Run Test Suite
        run: pytest tests/
```

### Pattern B: Isolated Job Containers (Recommended)
Keep runner clusters small and generic. Pass task-specific toolchains as container tags. This avoids scaling up custom VMs for each language combination:
```yaml
jobs:
  test:
    runs-on: [self-hosted, generic] # Runs on light scheduler (images/runner-generic)
    container:
      image: ghcr.io/yourorg/build-python312:latest # Job runs inside this container
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      - name: Verify Environment
        run: python --version # Runs inside the build-python312 sibling container
```

---

## 📖 Deep Dives & Documentation

For detailed information on configuring and managing this platform, consult the comprehensive guides in the `/docs` directory:

*   [Executive Summary & ARC Comparison](file:///d:/repositories/github-selfhosted-runner/docs/executive-summary-and-comparison.md): Feature comparison matrix, cost ROI metrics, and architectural decision flowcharts.
*   [Detailed Feature Explanations](file:///d:/repositories/github-selfhosted-runner/docs/detailed-feature-explanations.md): Mechanisms of auto-healing, predictive scaling, KEDA settings, and security controls.
*   [Infrastructure Setup Guide](file:///d:/repositories/github-selfhosted-runner/docs/infrastructure-setup-guide.md): Complete setup walkthroughs for AWS/Azure/GCP clusters, including Karpenter provisioning models.
*   [Advanced Features Configuration](file:///d:/repositories/github-selfhosted-runner/docs/advanced-features-configuration.md): Deep-dive into Gatekeeper constraints, Kyverno rules, VPA policies, and Kube-downscaler configs.
*   [Job Container Pattern Guide](file:///d:/repositories/github-selfhosted-runner/docs/job-container.md): Step-by-step setup details for the `job-containers/` split pattern vs. nested Docker-in-Docker.
*   [Resource Naming Conventions](file:///d:/repositories/github-selfhosted-runner/docs/namingconvension.md): Consistent tag patterns for resource groups, virtual networks, and subnets.