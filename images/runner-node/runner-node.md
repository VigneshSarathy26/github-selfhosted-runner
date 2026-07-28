# Node.js Runner Dockerfile

This documentation details the runner-node image Dockerfile, which extends the base runner image with Node.js and its associated package managers.

## General Information
- **Repository Path**: [images/runner-node/Dockerfile](file:///D:/repositories/github-selfhosted-runner/images/runner-node/Dockerfile)
- **Status**: Active
- **Purpose**: A runner environment tailored for building, testing, and deploying Node.js applications.

## Key Features & Toolchain
- **Inherited Base**: `github-runner-ubuntu:1.0.0`
- **Installed Utilities**:
  - `Node.js` & `npm` (Installed via official NodeSource repository)
- **Version Management & Wrapper Script**:
  - Reads target Node.js release line dynamically from `node-version` (e.g., `24.x`).
  - Downloads and runs the NodeSource setup script (`https://deb.nodesource.com/setup_${NODE_VERSION}`) to configure apt repositories and install `nodejs`.
  - Dynamically builds `/actions-runner/wrapper.sh` to export dynamic runner labels (`node${NODE_VERSION},ubuntu24`) and delegate execution to `/actions-runner/start.sh`.
  - Sets container `ENTRYPOINT` to `/actions-runner/wrapper.sh`.

## Dockerfile Source Code

```dockerfile
FROM github-runner-ubuntu:1.0.0
COPY node-version node-version
WORKDIR /actions-runner
RUN NODE_VERSION=$(cat node-version) && \
    curl -sL https://deb.nodesource.com/setup_${NODE_VERSION} -o /tmp/nodesource_setup.sh && \
    sudo bash /tmp/nodesource_setup.sh && \
    sudo apt-get install -y nodejs && \
    echo "#!/bin/bash" > /actions-runner/wrapper.sh && \
    echo "export RUNNER_LABELS=\"node${NODE_VERSION},ubuntu24\"" >> /actions-runner/wrapper.sh && \
    echo "exec /actions-runner/start.sh" >> /actions-runner/wrapper.sh && \
    sudo chmod +x /actions-runner/wrapper.sh

# Override the entrypoint to use our new wrapper
ENTRYPOINT ["/actions-runner/wrapper.sh"]
```
