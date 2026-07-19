# Terraform Job Container Dockerfile

This documentation details the build-terraform Dockerfile, which builds the environment used for runner workflows executing within a dedicated Terraform container.

## General Information
- **Repository Path**: [job-containers/build-terraform/Dockerfile](file:///D:/repositories/github-selfhosted-runner/job-containers/build-terraform/Dockerfile)
- **Status**: Proposed / Placeholder
- **Purpose**: Designed as a specialized build container (used via the GitHub Actions workflow `container:` key) rather than a persistent runner agent pod.

## Key Features & Toolchain
- **Base Image**: HashiCorp Terraform Linux Image (e.g. `hashicorp/terraform:latest`)
- **Key Utilities**:
  - Terraform core binary and basic tools

## Proposed Dockerfile Source Code
*(The repository file is currently empty/under development. Below is the proposed layout to implement these requirements)*

```dockerfile
# Proposed Dockerfile for build-terraform
FROM hashicorp/terraform:latest

RUN apk add --no-cache \
    git \
    curl \
    bash

WORKDIR /app
CMD ["terraform", "--version"]
```
