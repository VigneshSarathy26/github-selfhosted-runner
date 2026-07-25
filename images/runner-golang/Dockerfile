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
    && echo "export RUNNER_LABELS=ubuntu24,golang,go-$GO_VERSION" >> /home/agent/.bashrc