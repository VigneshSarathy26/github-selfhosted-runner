# Terraform / Infrastructure Runner Dockerfile

This documentation details the runner-terraform image Dockerfile, which extends the base runner image with infrastructure-as-code (IaC) tooling and major cloud command-line interfaces.

## General Information
- **Repository Path**: [images/runner-terraform/Dockerfile](file:///D:/repositories/github-selfhosted-runner/images/runner-terraform/Dockerfile)
- **Status**: Proposed / Placeholder
- **Purpose**: A specialized runner environment configured for linting, planning, testing, and applying cloud infrastructure modifications.

## Key Features & Toolchain
- **Inherited Base**: `base-runner` (built from [base/Dockerfile](file:///D:/repositories/github-selfhosted-runner/base/Dockerfile))
- **Additional Utilities**:
  - `Terraform` (infrastructure provisioning tool)
  - `tflint` (linter for Terraform configuration)
  - `AWS CLI` (Amazon Web Services CLI tool)
  - `gcloud CLI` (Google Cloud Platform SDK/CLI tool)
  - `Azure CLI` (Note: Azure CLI is already installed in the base image, but it can be referenced/updated here)

## Proposed Dockerfile Source Code
*(The repository file is currently empty/under development. Below is the proposed layout to implement these requirements)*

```dockerfile
# Proposed Dockerfile for runner-terraform
FROM selfhosted-runner-base:latest

USER root

# Install Terraform & HashiCorp GPG key
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com noble main" | tee /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && apt-get install -y terraform && \
    rm -rf /var/lib/apt/lists/*

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Install gcloud CLI
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/contained-releases/key | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    apt-get update && apt-get install -y google-cloud-cli && \
    rm -rf /var/lib/apt/lists/*

# Install tflint
RUN curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

USER agent
```
