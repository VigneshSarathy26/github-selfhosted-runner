# Node.js Runner Dockerfile

This documentation details the runner-node image Dockerfile, which extends the base runner image with Node.js and its associated package managers.

## General Information
- **Repository Path**: [images/runner-node/Dockerfile](file:///D:/repositories/github-selfhosted-runner/images/runner-node/Dockerfile)
- **Status**: Proposed / Placeholder
- **Purpose**: A runner environment tailored for building, testing, and deploying Node.js applications.

## Key Features & Toolchain
- **Inherited Base**: `base-runner` (built from [base/Dockerfile](file:///D:/repositories/github-selfhosted-runner/base/Dockerfile))
- **Additional Utilities**:
  - `Node.js` (latest LTS recommended)
  - `npm` (Node Package Manager)
  - `yarn` (Yarn package manager)
  - `pnpm` (Performant npm package manager)

## Proposed Dockerfile Source Code
*(The repository file is currently empty/under development. Below is the proposed layout to implement these requirements)*

```dockerfile
# Proposed Dockerfile for runner-node
FROM selfhosted-runner-base:latest

USER root

# Install Node.js LTS and package managers
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn pnpm && \
    rm -rf /var/lib/apt/lists/*

USER agent
```
