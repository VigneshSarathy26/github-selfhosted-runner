# Python Runner Dockerfile

This documentation details the runner-python image Dockerfile, which extends the base runner image with Python and standard dependency management tools.

## General Information
- **Repository Path**: [images/runner-python/Dockerfile](file:///D:/repositories/github-selfhosted-runner/images/runner-python/Dockerfile)
- **Status**: Proposed / Placeholder
- **Purpose**: A runner environment designed for Python development, testing, linting, packaging, and deployment workflows.

## Key Features & Toolchain
- **Inherited Base**: `base-runner` (built from [base/Dockerfile](file:///D:/repositories/github-selfhosted-runner/base/Dockerfile))
- **Additional Utilities**:
  - `Python 3`
  - `pip` (Python Package Installer)
  - `poetry` (Python packaging and dependency manager)
  - `virtualenv` / `python3-venv` (Virtual environment support)

## Proposed Dockerfile Source Code
*(The repository file is currently empty/under development. Below is the proposed layout to implement these requirements)*

```dockerfile
# Proposed Dockerfile for runner-python
FROM selfhosted-runner-base:latest

USER root

# Install Python 3, pip, and Poetry
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install poetry globally
RUN curl -sSL https://install.python-poetry.org | python3 -

# Add poetry to path
ENV PATH="/home/agent/.local/bin:$PATH"

USER agent
```
