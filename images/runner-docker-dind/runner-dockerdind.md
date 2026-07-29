# Docker-in-Docker (DinD) Runner Dockerfile

This documentation details the runner-docker-dind image Dockerfile, which extends the base runner image with Docker-in-Docker capabilities and Docker Buildx.

## General Information
- **Repository Path**: [images/runner-docker-dind/Dockerfile](file:///D:/repositories/github-selfhosted-runner/images/runner-docker-dind/Dockerfile)
- **Status**: Active
- **Purpose**: A runner environment designed to build, run, and push Docker containers. Useful for CI/CD pipelines that compile images or run containerized integration tests.

## Key Features & Toolchain
- **Inherited Base**: `github-runner-ubuntu:1.0.0`
- **User & Permissions**: `runner` user with passwordless `sudo` access
- **Environment Variables**:
  - `TARGETARCH="linux-x64"`
  - `TZ=UTC`
  - `DEBIAN_FRONTEND=noninteractive`
  - `RUNNER_LABELS=docker-dind,ubuntu24`
- **Installed Utilities & Packages**:
  - `ca-certificates`, `curl`, `gnupg`, `lsb-release`
  - `docker-ce` (Docker Engine daemon)
  - `docker-ce-cli` (Docker CLI)
  - `containerd.io` (Container runtime)
  - `docker-buildx-plugin` (Docker Buildx multi-platform build plugin)

## Dockerfile Source Code

```dockerfile
FROM github-runner-ubuntu:1.0.0

# Set labels
ENV TARGETARCH="linux-x64" \
    TZ=UTC \
    DEBIAN_FRONTEND=noninteractive \
    RUNNER_LABELS=docker-dind,ubuntu24
# Add a new runner user
RUN useradd -m -d /home/runner runner \
    && echo "runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

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

USER runner
```
