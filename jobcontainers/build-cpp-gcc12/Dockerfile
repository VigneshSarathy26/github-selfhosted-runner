FROM gcc:12

RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake ninja-build git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
