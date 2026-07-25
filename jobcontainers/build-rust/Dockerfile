# FROM rust:1.75-slim is used to build the image.
FROM rust:1.75-slim

# apk add --no-cache curl git bash installs the following packages
# curl - Transfer a URL
# git - The distributed version control system
# bash - GNU Bash Shell
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git \
    && rm -rf /var/lib/apt/lists/*
# RUN rustup component add clippy rustfmt adds the clippy and rustfmt components to the Rust installation
RUN rustup component add clippy rustfmt
# Set the working directory to /workspace
WORKDIR /workspace
