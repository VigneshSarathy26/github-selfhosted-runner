# Node 20 Job Container Dockerfile

This documentation details the build-node20 Dockerfile, which builds the environment used for runner workflows executing within a dedicated Node 20 container.

## General Information
- **Repository Path**: [job-containers/build-node20/Dockerfile](file:///D:/repositories/github-selfhosted-runner/job-containers/build-node20/Dockerfile)
- **Status**: Proposed / Placeholder
- **Purpose**: Designed as a specialized build container (used via the GitHub Actions workflow `container:` key) rather than a persistent runner agent pod.

## Key Features & Toolchain
- **Base Image**: Node.js 20 Official Linux Image (e.g. `node:20-slim`)
- **Key Utilities**:
  - Node.js runtime and yarn/pnpm package managers
  - Essential system build tools

## Proposed Dockerfile Source Code
*(The repository file is currently empty/under development. Below is the proposed layout to implement these requirements)*

```dockerfile
# Proposed Dockerfile for build-node20
FROM node:20-slim

RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
CMD ["node"]
```
