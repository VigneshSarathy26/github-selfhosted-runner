#FROM node:20-slim is used to build the image.
FROM node:20-slim

# RUN npm install -g eslint prettier installs eslint and prettier globally.
RUN npm install -g eslint prettier

# Install system dependencies for linting.
RUN apt-get update && apt-get install -y --no-install-recommends \
    shellcheck python3-pip git \
    && pip3 install --no-cache-dir --break-system-packages black \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory to /workspace   
WORKDIR /workspace
