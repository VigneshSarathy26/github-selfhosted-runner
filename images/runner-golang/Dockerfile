# /images/runner-golang/Dockerfile

FROM github-runner-ubuntu:1.0.0

COPY go-version go-version

USER agent

# Add golang to the image, and persist GO_VERSION + RUNNER_LABELS
# into a file that gets sourced into the container's environment.
RUN GO_VERSION="$(cat go-version)" \
    && wget "https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz" \
    && sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz" \
    && rm "go${GO_VERSION}.linux-amd64.tar.gz" \
    && echo "GO_VERSION=${GO_VERSION}" | sudo tee -a /etc/environment \
    && echo "RUNNER_LABELS=ubuntu24,golang,go-${GO_VERSION}" | sudo tee -a /etc/environment

ENV GOROOT=/usr/local/go
ENV GOPATH=/home/agent/go
ENV PATH=$PATH:/usr/local/go/bin:/home/agent/go/bin
