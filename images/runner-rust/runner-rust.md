# Rust Runner Dockerfile

This documentation details the runner-rust image Dockerfile, which extends the base runner image with the official Rust toolchain via `rustup`.

## General Information
- **Repository Path**: [images/runner-rust/Dockerfile](file:///D:/repositories/github-selfhosted-runner/images/runner-rust/Dockerfile)
- **Status**: Active
- **Purpose**: A specialized runner environment for building, testing, linting, and compiling Rust projects and Cargo packages.

## Key Features & Toolchain
- **Inherited Base**: `github-runner-ubuntu:1.0.0`
- **Toolchain & Installation**:
  - Installs the official Rust toolchain via `rustup` (`https://sh.rustup.rs`).
  - Includes `cargo`, `rustc`, `rustdoc`, and Cargo package manager binaries.
- **Environment & Wrapper Script**:
  - Dynamically builds `/actions-runner/wrapper.sh` to add `$HOME/.cargo/bin` to `PATH`.
  - Sets runtime runner labels: `export RUNNER_LABELS="rust,ubuntu24"`.
  - Executes `/actions-runner/start.sh` to start the runner daemon.
  - Sets container `ENTRYPOINT` to `/actions-runner/wrapper.sh`.

## Dockerfile Source Code

```dockerfile
# Base image
FROM github-runner-ubuntu:1.0.0

# Install Rust toolchain and override the entrypoint to use our new wrapper
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh \
    && echo "#!/bin/bash" > /actions-runner/wrapper.sh \
    && echo "export PATH=\"$HOME/.cargo/bin:$PATH\"" >> /actions-runner/wrapper.sh \
    && echo "export RUNNER_LABELS=\"rust,ubuntu24\"" >> /actions-runner/wrapper.sh \
    && echo "exec /actions-runner/start.sh" >> /actions-runner/wrapper.sh \
    && sudo chmod +x /actions-runner/wrapper.sh

# Override the entrypoint to use our new wrapper
ENTRYPOINT ["/actions-runner/wrapper.sh"]
```
