# Docker-in-Docker (DinD) Runner Dockerfile

This documentation details the runner-docker-dind image Dockerfile, which extends the base runner image with Docker-in-Docker capabilities and Docker Buildx.

## General Information
- **Repository Path**: [images/runner-docker-dind/Dockerfile](file:///D:/repositories/github-selfhosted-runner/images/runner-docker-dind/Dockerfile)
- **Status**: Proposed / Placeholder
- **Purpose**: A runner environment designed to build, run, and push Docker containers. Useful for CI/CD pipelines that compile images or run containerized integration tests.

## Key Features & Toolchain
- **Inherited Base**: `base-runner` (built from [base/Dockerfile](file:///D:/repositories/github-selfhosted-runner/base/Dockerfile))
- **Additional Utilities**:
  - `Docker CLI` & daemon components
  - `Docker Buildx` (multi-platform container builds)
  - `Docker Compose`

## Proposed Dockerfile Source Code
*(The repository file is currently empty/under development. Below is the proposed layout to implement these requirements)*

```dockerfile
# Proposed Dockerfile for runner-docker-dind
FROM selfhosted-runner-base:latest

USER root

# Install Docker engine and buildx
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg

RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update && apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

USER agent
```
