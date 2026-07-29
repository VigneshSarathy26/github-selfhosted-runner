# Base image
FROM github-runner-ubuntu:1.0.0

# Install Rust toolchain and override the entrypoint to use our new wrapper
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh \
    && echo "#!/bin/bash" > /actions-runner/wrapper.sh \
    && echo "export PATH=\"$HOME/.cargo/bin:$PATH\"" >> /actions-runner/wrapper.sh \
    && echo "export RUNNER_LABELS=\"rust,ubuntu24\"" >> /actions-runner/wrapper.sh \
    && echo "exec /actions-runner/start.sh" >> /actions-runner/wrapper.sh \
    && sudo chmod +x /actions-runner/wrapper.sh

# Override the entrypoint to use our new wrapper
ENTRYPOINT ["/actions-runner/wrapper.sh"]
