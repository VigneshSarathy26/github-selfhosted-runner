FROM node:20-slim

RUN npm install -g eslint prettier

RUN apt-get update && apt-get install -y --no-install-recommends \
    shellcheck python3-pip git \
    && pip3 install --no-cache-dir --break-system-packages black \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
