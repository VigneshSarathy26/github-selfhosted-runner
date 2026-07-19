# Python 3.12 Job Container Dockerfile

This documentation details the build-python312 Dockerfile, which builds the environment used for runner workflows executing within a dedicated Python 3.12 container.

## General Information
- **Repository Path**: [job-containers/build-python312/Dockerfile](file:///D:/repositories/github-selfhosted-runner/job-containers/build-python312/Dockerfile)
- **Status**: Proposed / Placeholder
- **Purpose**: Designed as a specialized build container (used via the GitHub Actions workflow `container:` key) rather than a persistent runner agent pod.

## Key Features & Toolchain
- **Base Image**: Python 3.12 Official Linux Image (e.g. `python:3.12-slim`)
- **Key Utilities**:
  - Python toolchain & packages
  - Standard development libraries needed for compiling python extensions

## Proposed Dockerfile Source Code
*(The repository file is currently empty/under development. Below is the proposed layout to implement these requirements)*

```dockerfile
# Proposed Dockerfile for build-python312
FROM python:3.12-slim

RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
CMD ["python3"]
```
