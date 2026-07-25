# FROM node:20-slim is used to build the image
FROM node:20-slim

# RUN apt-get update && apt-get install -y --no-install-recommends \
#     git curl \
#     && rm -rf /var/lib/apt/lists/*
# git - The distributed version control system
# curl - Transfer a URL

RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory to /workspace
WORKDIR /workspace
