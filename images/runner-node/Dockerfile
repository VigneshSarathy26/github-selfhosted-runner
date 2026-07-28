FROM github-runner-ubuntu:1.0.0
COPY node-version node-version
WORKDIR /actions-runner
RUN NODE_VERSION=$(cat node-version) && \
    curl -sL https://deb.nodesource.com/setup_${NODE_VERSION} -o /tmp/nodesource_setup.sh && \
    sudo bash /tmp/nodesource_setup.sh && \
    sudo apt-get install -y nodejs && \
    echo "#!/bin/bash" > /actions-runner/wrapper.sh && \
    echo "export RUNNER_LABELS=\"node${NODE_VERSION},ubuntu24\"" >> /actions-runner/wrapper.sh && \
    echo "exec /actions-runner/start.sh" >> /actions-runner/wrapper.sh && \
    sudo chmod +x /actions-runner/wrapper.sh

# Override the entrypoint to use our new wrapper
ENTRYPOINT ["/actions-runner/wrapper.sh"]