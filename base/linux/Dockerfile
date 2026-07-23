FROM ubuntu:24.04

# Set environment variables
# Note: Added DEBIAN_FRONTEND=noninteractive to prevent apt from hanging on user prompts
ENV TARGETARCH="linux-x64" \
    TZ=UTC \
    RUNNER_VERSION=2.335.1 \
    DEBIAN_FRONTEND=noninteractive \
    RUNNER_LABELS=base,ubuntu

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

WORKDIR /actions-runner/
# Copy the start script to the runner directory
COPY start.sh  /actions-runner/start.sh
RUN chmod +x /actions-runner/start.sh

# Create agent user, set up home directory, and configure passwordless sudo
RUN useradd -m -d /home/agent agent \
    && echo "agent ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && chown -R agent:agent /actions-runner

USER agent

# Set the correct entrypoint to run the script
ENTRYPOINT ["/actions-runner/start.sh"]