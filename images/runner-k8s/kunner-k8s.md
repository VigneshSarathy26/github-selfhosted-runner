# Kubernetes Runner Dockerfile

This documentation details the runner-k8s image Dockerfile, which extends the base runner image with Kubernetes CLI (`kubectl`) tools for managing Kubernetes clusters.

## General Information
- **Repository Path**: [images/runner-k8s/Dockerfile](file:///D:/repositories/github-selfhosted-runner/images/runner-k8s/Dockerfile)
- **Status**: Active
- **Purpose**: A specialized runner environment designed for deploying, managing, and interacting with Kubernetes clusters via `kubectl`.

## Key Features & Toolchain
- **Inherited Base**: `github-runner-ubuntu:1.0.0`
- **Environment Variables**:
  - `TARGETARCH="linux-x64"`
  - `TZ=UTC`
  - `DEBIAN_FRONTEND=noninteractive`
- **Installed Utilities**:
  - `apt-transport-https`, `ca-certificates`, `curl`, `gnupg`
  - `kubectl` (Kubernetes command-line tool)
- **Version Management & Wrapper Script**:
  - Reads target Kubernetes version dynamically from `k8s-version` (e.g., `v1.36`).
  - Configures the official Kubernetes apt package repository (`https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/deb/`) and installs `kubectl`.
  - Dynamically builds `/actions-runner/wrapper.sh` to export dynamic runner labels (`kubernetes-${K8S_VERSION},ubuntu24`) and delegate to `/actions-runner/start.sh`.
  - Sets container `ENTRYPOINT` to `/actions-runner/wrapper.sh`.

## Dockerfile Source Code

```dockerfile
# Dockerfile
FROM github-runner-ubuntu:1.0.0

# Set labels
ENV TARGETARCH="linux-x64" \
    TZ=UTC \
    DEBIAN_FRONTEND=noninteractive 

COPY k8s-version k8s-version

# 1. Read the file
# 2. Install k8s
# 3. Create a wrapper script that sets the label and calls the original start.sh
RUN K8S_VERSION=$(cat k8s-version) \
    && sudo apt-get update \
    && sudo apt-get install -y apt-transport-https ca-certificates curl gnupg \
    && sudo mkdir -p -m 755 /etc/apt/keyrings \
    && curl -fsSL https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg \
    && sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list \
    && sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list \
    && sudo apt-get update \
    && sudo apt-get install -y kubectl \
    && sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/* \
    && echo "#!/bin/bash" > /actions-runner/wrapper.sh \
    && echo "export RUNNER_LABELS=\"kubernetes-${K8S_VERSION},ubuntu24\"" >> /actions-runner/wrapper.sh \
    && echo "exec /actions-runner/start.sh" >> /actions-runner/wrapper.sh \
    && sudo chmod +x /actions-runner/wrapper.sh

# Override the entrypoint to use our new wrapper
ENTRYPOINT ["/actions-runner/wrapper.sh"]
```
