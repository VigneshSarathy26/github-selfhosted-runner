FROM baselximage:v1.0.0

# Set labels
LABEL runner.type="docker-dind" \
    runner.version="1.0.0" \
    maintainer="mr.devops@gmail.com" 

# Install Docker Engine (not just the CLI — DinD needs the daemon too)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg lsb-release \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list \
    && apt-get update && apt-get install -y --no-install-recommends \
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin \
    && rm -rf /var/lib/apt/lists/*

RUN usermod -aG docker runner

USER runner