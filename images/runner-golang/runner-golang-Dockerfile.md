# Go Runner Dockerfile

This documentation details the runner-golang image Dockerfile, which extends the base runner image with the Go programming language toolchain.

## General Information
- **Repository Path**: [images/runner-golang/Dockerfile](file:///D:/repositories/github-selfhosted-runner/images/runner-golang/Dockerfile)
- **Status**: Proposed / Placeholder
- **Purpose**: A runner environment specialized for compiling, building, testing, linting, and running Go/Golang services.

## Key Features & Toolchain
- **Inherited Base**: `base-runner` (built from [base/Dockerfile](file:///D:/repositories/github-selfhosted-runner/base/Dockerfile))
- **Additional Utilities**:
  - `Go Toolchain` (compilers, build, and formatting tools)
  - `GOPATH` and binary execution environment configurations

## Proposed Dockerfile Source Code
*(The repository file is currently empty/under development. Below is the proposed layout to implement these requirements)*

```dockerfile
# Proposed Dockerfile for runner-golang
FROM selfhosted-runner-base:latest

USER root

# Install Go toolchain
ENV GO_VERSION=1.22.0
RUN curl -OL https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz

# Configure Go paths
ENV GOPATH=/home/agent/go
ENV PATH="/usr/local/go/bin:$GOPATH/bin:$PATH"

USER agent
```
