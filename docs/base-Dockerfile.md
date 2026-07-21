# Base Runner Dockerfile

This documentation details the base Dockerfile used to build the foundational environment for all GitHub self-hosted runner agents in this project.

## General Information
- **Repository Path**: [base/Dockerfile](file:///D:/repositories/github-selfhosted-runner/base/Dockerfile)
- **Status**: Implemented / Stable
- **Purpose**: Serves as the shared base image containing core utilities, the runner agent installation tools, environment setup, and the entrypoint registration script.

## Key Features & Toolchain
- **Parent Image**: `ubuntu:24.04` (Ubuntu Noble Numbat)
- **Architecture Support**: Configured for `linux-x64` by default (configurable via `TARGETARCH`).
- **Runner Version**: GitHub Actions runner agent version `2.335.1`.
- **System Utilities**:
  - `curl`
  - `git`
  - `ca-certificates`
  - `gnupg`
  - `lsb-release`
  - `software-properties-common`
  - `wget`
  - `sudo`
  - `jq`
  - `unzip`
  - `tar`
  - `xz-utils`
- **Cloud Tooling**:
  - Azure CLI (installed via the official deb installation script)
- **Security & Permissions**:
  - Sets up a non-root system user named `agent` with home directory `/home/agent`.
  - Configures the workspace folder `/actions-runner/` with the appropriate ownership for user `agent`.
  - Configures container entrypoint via an execution script [entrypoint.sh](file:///D:/repositories/github-selfhosted-runner/base/entrypoint.sh).

## Dockerfile Source Code

```dockerfile
FROM ubuntu:24.04

# Set the target architecture for the GitHub Actions runner. The default is "linux-x64".

ENV TARGETARCH="linux-x64" \
    TZ=UTC \
    RUNNER_VERSION=2.335.1 
    
# Also can be "linux-arm", "linux-arm64".

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    wget \
    sudo \
    jq \
    unzip \
    tar \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

WORKDIR /actions-runner/
COPY entrypoint.sh /actions-runner/entrypoint.sh
RUN chmod +x /actions-runner/entrypoint.sh
# Create agent user, set up home directory, and configure passwordless sudo
RUN useradd -m -d /home/agent agent \
    && echo "agent ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN chown -R agent:agent /actions-runner

USER agent


ENTRYPOINT [ "./entrypoint.sh" ]
```
