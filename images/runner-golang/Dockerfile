FROM github-runner-ubuntu:1.0.0

COPY go-version go-version

USER agent

ENV GOROOT=/usr/local/go
ENV GOPATH=/home/agent/go
ENV PATH=$PATH:/usr/local/go/bin:/home/agent/go/bin

# Read the file, install Go, and write the labels to a profile file
RUN GO_VERSION="$(cat go-version)" \
    && wget "https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz" \
    && sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz" \
    && rm "go${GO_VERSION}.linux-amd64.tar.gz" \
    && sudo rm -rf /var/lib/apt/lists/* \
    && echo "#!/bin/bash" > /actions-runner/wrapper.sh \
    && echo "export RUNNER_LABELS=\"golang,go-${GO_VERSION},ubuntu24\"" >> /actions-runner/wrapper.sh \
    && echo "exec /actions-runner/start.sh" >> /actions-runner/wrapper.sh \
    && sudo chmod +x /actions-runner/wrapper.sh
ENTRYPOINT ["/actions-runner/wrapper.sh"]