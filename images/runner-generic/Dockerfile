# images/runner-generic/Dockerfile
ARG BASE_IMAGE=github-runner-base:latest
FROM ${BASE_IMAGE}

# Set labels
LABEL runner.type="generic" \
    runner.version="1.0.0" \
    maintainer="mr.devops@gmail.com" 

# Set default labels for runner
ENV RUNNER_LABELS="self-hosted,Linux,X64,generic"

# Additional tools for generic runner
RUN sudo apt-get update && sudo apt-get install -y \
    htop \
    tree \
    ncdu \
    ripgrep \
    fd-find \
    && sudo rm -rf /var/lib/apt/lists/*

# Install Azure CLI
RUN curl -fsSL 'https://azurecliprod.blob.core.windows.net/$root/deb_install.sh' | sudo bash
# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN sudo ./aws/install
# Install Google Cloud CLI
RUN curl https://sdk.cloud.google.com | bash
