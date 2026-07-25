# Base Runner Dockerfile (Linux)

This documentation details the Linux base Dockerfile used to build the foundational environment for all Linux GitHub self-hosted runner agents in this project.

## General Information
- **Repository Path**: [base/linux/Dockerfile](file:///D:/repositories/github-selfhosted-runner/base/linux/Dockerfile)
- **Status**: Implemented / Stable
- **Purpose**: Serves as the shared base image containing core utilities, system dependencies, Azure CLI, user configuration, and the entrypoint execution script.

## Key Features & Toolchain
- **Parent Image**: `ubuntu:24.04` (Ubuntu Noble Numbat)
- **Architecture Support**: Configured for `linux-x64` by default (configurable via `TARGETARCH`).
- **Runner Version**: GitHub Actions runner agent version `2.335.1`.

## Installed Packages

### Quick Reference

| Category | Packages Installed |
| :--- | :--- |
| **System Utilities & Tools** | `curl`, `git`, `ca-certificates`, `gnupg`, `lsb-release`, `software-properties-common`, `wget`, `sudo`, `jq`, `unzip`, `tar`, `xz-utils` |
| **Cloud & CLI Tooling** | `azure-cli` |

### Package Details

| Package Name | Category | Description / Purpose |
| :--- | :--- | :--- |
| `curl` | Transfer Utility | Command line tool for transferring data with URLs |
| `git` | Version Control | Distributed version control system required for GitHub Actions checkout |
| `ca-certificates` | Security | Common CA certificates for SSL/TLS verification |
| `gnupg` | Security | OpenPGP encryption and signing tool |
| `lsb-release` | System Info | Linux Standard Base version reporting utility |
| `software-properties-common` | Package Management | Managing PPA and software repository specifications |
| `wget` | Transfer Utility | Non-interactive network downloader |
| `sudo` | Security / Access | Privilege delegation tool allowing passwordless root execution for `agent` |
| `jq` | Data Processing | Lightweight and flexible command-line JSON processor |
| `unzip` | Archive Utility | Extraction utility for `.zip` compressed archives |
| `tar` | Archive Utility | Archiving tool for `.tar.gz` and `.tar` files |
| `xz-utils` | Compression | Compression and decompression utilities for XZ format archives |
| `azure-cli` | Cloud Tooling | Official Microsoft Azure Command-Line Interface |

## Security & Permissions
- Sets up a non-root system user named `agent` with home directory `/home/agent`.
- Configures the workspace folder `/actions-runner/` with the appropriate ownership for user `agent`.
- Configures container entrypoint via an execution script [start.sh](file:///D:/repositories/github-selfhosted-runner/base/linux/start.sh).

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
COPY start.sh  /actions-runner/start.sh

RUN chmod +x /actions-runner/start.sh
# Create agent user, set up home directory, and configure passwordless sudo
RUN useradd -m -d /home/agent agent \
    && echo "agent ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN chown -R agent:agent /actions-runner

USER agent


ENTRYPOINT [ "start.sh" ]
```

## Startup Script Source Code (`start.sh`)

```bash
#!/bin/bash
set -e

cd /actions-runner
curl -f -o actions-runner-${TARGETARCH}-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-${TARGETARCH}-${RUNNER_VERSION}.tar.gz
tar xzf ./actions-runner-${TARGETARCH}-${RUNNER_VERSION}.tar.gz
./config.sh --url $RUNNER_URL --token $RUNNER_TOKEN --labels $RUNNER_LABELS
./run.sh
```
