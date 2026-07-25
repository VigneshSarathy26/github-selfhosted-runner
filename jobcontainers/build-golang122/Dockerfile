# FROM golang:1.22-bookworm is used to build the image
FROM golang:1.22-bookworm

# RUN apt-get update && apt-get install -y --no-install-recommends \
#     git ca-certificates \
#     && rm -rf /var/lib/apt/lists/*
# git - The distributed version control system
# ca-certificates - CA certificates for TLS/SSL

RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# RUN go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
# golangci-lint - Fast linter for Go

WORKDIR /workspace
