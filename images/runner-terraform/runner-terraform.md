# Terraform / Infrastructure Runner Dockerfile

This documentation details the runner-terraform image Dockerfile, which extends the base runner image with HashiCorp Terraform and major cloud provider command-line interfaces.

## General Information
- **Repository Path**: [images/runner-terraform/Dockerfile](file:///D:/repositories/github-selfhosted-runner/images/runner-terraform/Dockerfile)
- **Status**: Active
- **Purpose**: A specialized runner environment configured for linting, planning, testing, and applying cloud infrastructure modifications using Terraform across AWS, Azure, and Google Cloud Platform.

## Key Features & Toolchain
- **Inherited Base**: `github-runner-ubuntu:1.0.0`
- **Environment Variables**:
  - `TARGETARCH="linux-x64"`
  - `TZ=UTC`
  - `RUNNER_LABELS=terraform,ubuntu`
- **Installed Utilities & Cloud CLIs**:
  - `Terraform` (HashiCorp infrastructure provisioning tool, installed via official HashiCorp apt repository)
  - `Azure CLI` (Installed via official Microsoft install script)
  - `AWS CLI v2` (Installed via official AWS Linux ZIP bundle)
  - `Google Cloud CLI` (Installed via Google Cloud SDK setup script)

## Dockerfile Source Code

```dockerfile
FROM github-runner-ubuntu:1.0.0
# environment variables
ENV TARGETARCH="linux-x64" \
    TZ=UTC \
    RUNNER_LABELS=terraform,ubuntu

# Install Terraform
RUN wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list \
    && sudo apt update && sudo apt install terraform -y

# Install Azure CLI
RUN curl -fsSL 'https://azurecliprod.blob.core.windows.net/$root/deb_install.sh' | sudo bash
# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN sudo ./aws/install
# Install Google Cloud CLI
RUN curl https://sdk.cloud.google.com | bash
```
