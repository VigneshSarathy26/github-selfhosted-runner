# Generic Runner Dockerfile

This documentation details the runner-generic image Dockerfile, which extends the base runner image with system administration utilities and cloud provider CLI tools.

## General Information
- **Repository Path**: [images/runner-generic/Dockerfile](file:///D:/repositories/github-selfhosted-runner/images/runner-generic/Dockerfile)
- **Status**: Active
- **Purpose**: A general-purpose runner equipped with system utilities and cloud CLIs (AWS, Azure, Google Cloud) for multi-cloud deployment and maintenance workflows.

## Key Features & Toolchain
- **Inherited Base**: `github-runner-ubuntu:1.0.0`
- **Environment Variables**:
  - `TARGETARCH="linux-x64"`
  - `TZ=UTC`
  - `RUNNER_LABELS=ubuntu24,generic`
- **Installed Utilities**:
  - `htop` (Interactive process viewer)
  - `tree` (Directory structure viewer)
  - `ncdu` (NCurses disk usage analyzer)
  - `ripgrep` (Fast text search tool)
  - `fd-find` (Simple, fast alternative to find)
- **Cloud Provider CLIs**:
  - `Azure CLI`
  - `AWS CLI v2`
  - `Google Cloud SDK / CLI`

## Dockerfile Source Code

```dockerfile
# images/runner-generic/Dockerfile
FROM github-runner-ubuntu:1.0.0

# 
ENV TARGETARCH="linux-x64" \
    TZ=UTC \
    RUNNER_LABELS=ubuntu24,generic

# Additional tools for generic runner
RUN sudo apt-get update && sudo apt-get install -y \
    htop \
    tree \
    ncdu \
    ripgrep \
    fd-find \
    && sudo rm -rf /var/lib/apt/lists/*

# Install Azure CLI
RUN curl -fsSL 'https://azurecliprod.blob.core.windows.net/$root/deb_install.sh' | sudo bash
# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN sudo ./aws/install
# Install Google Cloud CLI
RUN curl https://sdk.cloud.google.com | bash
```
