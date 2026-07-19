# Generic Runner Dockerfile

This documentation details the runner-generic image Dockerfile, which extends the base runner image with additional basic shell and utility tools.

## General Information
- **Repository Path**: [images/runner-generic/Dockerfile](file:///D:/repositories/github-selfhosted-runner/images/runner-generic/Dockerfile)
- **Status**: Proposed / Placeholder
- **Purpose**: A general-purpose runner equipped with basic parsing tools and utilities needed by standard scripting jobs.

## Key Features & Toolchain
- **Inherited Base**: `base-runner` (built from [base/Dockerfile](file:///D:/repositories/github-selfhosted-runner/base/Dockerfile))
- **Additional Utilities**:
  - Basic shell utilities
  - `jq` (JSON processor)
  - `yq` (YAML processor)
  - `unzip` (ZIP archive extraction)

## Proposed Dockerfile Source Code
*(The repository file is currently empty/under development. Below is the proposed layout to implement these requirements)*

```dockerfile
# Proposed Dockerfile for runner-generic
FROM selfhosted-runner-base:latest

USER root

# Install generic utilities: yq, unzip, etc. (jq/unzip are in base, yq can be added)
RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && \
    chmod +x /usr/bin/yq

USER agent
```
