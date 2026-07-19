# GPU/ML Runner Dockerfile

This documentation details the runner-gpu-ml image Dockerfile, which extends the base runner image with CUDA support and Python tools for machine learning workloads.

## General Information
- **Repository Path**: [images/runner-gpu-ml/Dockerfile](file:///D:/repositories/github-selfhosted-runner/images/runner-gpu-ml/Dockerfile)
- **Status**: Proposed / Placeholder
- **Purpose**: A GPU-enabled runner environment specialized for executing ML/DL training, data science operations, and automated model testing pipelines.

## Key Features & Toolchain
- **Inherited Base**: `base-runner` (built from [base/Dockerfile](file:///D:/repositories/github-selfhosted-runner/base/Dockerfile))
- **Additional Utilities**:
  - `CUDA Toolkit` (provided by NVIDIA base images)
  - `Python 3` + `pip`
  - Machine learning frameworks (e.g. PyTorch, TensorFlow dependencies)

## Proposed Dockerfile Source Code
*(The repository file is currently empty/under development. Below is the proposed layout to implement these requirements)*

```dockerfile
# Proposed Dockerfile for runner-gpu-ml
# Note: Instead of ubuntu base, this often starts from an NVIDIA CUDA developer base
FROM nvidia/cuda:12.2.0-devel-ubuntu22.04

# Core dependencies similar to base-runner
ENV TARGETARCH="linux-x64" \
    TZ=UTC \
    RUNNER_VERSION=2.335.1 

RUN apt-get update && apt-get install -y \
    curl git ca-certificates gnupg lsb-release software-properties-common wget sudo jq unzip tar xz-utils \
    python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /actions-runner/
# Configure similar runner entrypoint
COPY entrypoint.sh /actions-runner/entrypoint.sh
RUN chmod +x /actions-runner/entrypoint.sh

RUN useradd -m -d /home/agent agent && chown -R agent:agent /actions-runner
USER agent

ENTRYPOINT [ "./entrypoint.sh" ]
```
