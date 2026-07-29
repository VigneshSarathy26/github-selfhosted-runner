# FROM ruby:3.2-slim is used to build the image.
FROM ruby:3.2-slim

# RUN apt-get update && apt-get install -y --no-install-recommends \
#     build-essential git \
#     && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory to /workspace    
WORKDIR /workspace
