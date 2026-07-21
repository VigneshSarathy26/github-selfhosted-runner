FROM ubuntu:24.04

# Set the target architecture for the GitHub Actions runner. The default is "linux-x64".

ENV TARGETARCH="linux-x64" \
    TZ=UTC \
    RUNNER_VERSION=2.335.1 

# Also can be "linux-arm", "linux-arm64".

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    wget \
    sudo \
    jq \
    unzip \
    tar \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

WORKDIR /actions-runner/
COPY entrypoint.sh /actions-runner/entrypoint.sh

RUN chmod +x /actions-runner/entrypoint.sh
# Create agent user, set up home directory, and configure passwordless sudo
RUN useradd -m -d /home/agent agent \
    && echo "agent ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN chown -R agent:agent /actions-runner

USER agent


ENTRYPOINT [ "script/entrypoint.sh" ]