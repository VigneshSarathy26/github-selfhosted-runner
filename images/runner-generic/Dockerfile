# images/runner-generic/Dockerfile
FROM github-runner-ubuntu:1.0.0

# 
ENV TARGETARCH="linux-x64" \
    TZ=UTC \
    RUNNER_LABELS=ubuntu24,generic

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

