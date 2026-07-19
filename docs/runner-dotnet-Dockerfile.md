# .NET Runner Dockerfile

This documentation details the runner-dotnet image Dockerfile, which extends the base runner image with the Microsoft .NET SDK.

## General Information
- **Repository Path**: [images/runner-dotnet/Dockerfile](file:///D:/repositories/github-selfhosted-runner/images/runner-dotnet/Dockerfile)
- **Status**: Proposed / Placeholder
- **Purpose**: A runner environment designed for compiling, testing, publishing, and deploying .NET applications.

## Key Features & Toolchain
- **Inherited Base**: `base-runner` (built from [base/Dockerfile](file:///D:/repositories/github-selfhosted-runner/base/Dockerfile))
- **Additional Utilities**:
  - `.NET SDK` (compilers, CLI toolchain, runtime, and package management tools)
  - NuGet CLI support

## Proposed Dockerfile Source Code
*(The repository file is currently empty/under development. Below is the proposed layout to implement these requirements)*

```dockerfile
# Proposed Dockerfile for runner-dotnet
FROM selfhosted-runner-base:latest

USER root

# Install Microsoft repository and .NET SDK
RUN wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb

RUN apt-get update && apt-get install -y \
    dotnet-sdk-8.0 \
    && rm -rf /var/lib/apt/lists/*

USER agent
```
