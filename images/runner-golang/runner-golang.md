# Go Runner Dockerfile

This documentation details the runner-golang image Dockerfile, which extends the base runner image with the Go programming language toolchain.

## General Information
- **Repository Path**: [images/runner-golang/Dockerfile](file:///D:/repositories/github-selfhosted-runner/images/runner-golang/Dockerfile)
- **Status**: Active
- **Purpose**: A runner environment specialized for compiling, building, testing, linting, and running Go/Golang services.

## Key Features & Toolchain
- **Inherited Base**: `github-runner-ubuntu:1.0.0`
- **User Context**: `agent`
- **Environment Variables**:
  - `GOROOT=/usr/local/go`
  - `GOPATH=/home/agent/go`
  - `PATH=$PATH:/usr/local/go/bin:/home/agent/go/bin`
- **Version Management & Wrapper Script**:
  - Reads the target Go version dynamically from the local `go-version` file (e.g., `1.25.12`).
  - Downloads and extracts the official Go Linux tarball to `/usr/local/go`.
  - Generates a custom `/actions-runner/wrapper.sh` wrapper script that exports dynamic runner labels (`golang`, `go-${GO_VERSION}`, `ubuntu24`) and executes `/actions-runner/start.sh`.
  - Configures container entrypoint to `/actions-runner/wrapper.sh`.

## Dockerfile Source Code

```dockerfile
FROM github-runner-ubuntu:1.0.0

COPY go-version go-version

USER agent

ENV GOROOT=/usr/local/go
ENV GOPATH=/home/agent/go
ENV PATH=$PATH:/usr/local/go/bin:/home/agent/go/bin

# Read the file, install Go, and write the labels to a profile file
RUN GO_VERSION="$(cat go-version)" \
    && wget "https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz" \
    && sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz" \
    && rm "go${GO_VERSION}.linux-amd64.tar.gz" \
    && sudo rm -rf /var/lib/apt/lists/* \
    && echo "#!/bin/bash" > /actions-runner/wrapper.sh \
    && echo "export RUNNER_LABELS=\"golang,go-${GO_VERSION},ubuntu24\"" >> /actions-runner/wrapper.sh \
    && echo "exec /actions-runner/start.sh" >> /actions-runner/wrapper.sh \
    && sudo chmod +x /actions-runner/wrapper.sh
ENTRYPOINT ["/actions-runner/wrapper.sh"]
```
