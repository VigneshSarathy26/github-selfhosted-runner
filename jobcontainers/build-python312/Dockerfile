# FROM python:3.12-slim is used to build the image
FROM python:3.12-slim
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     build-essential git curl \
#     && rm -rf /var/lib/apt/lists/*
# build-essential - Install build tools (gcc, make, etc.) 
# git - The distributed version control system
# curl - Transfer a URL    
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git curl \
    && rm -rf /var/lib/apt/lists/*
# RUN pip install --no-cache-dir poetry pytest
# poetry - Dependency management and packaging for Python
# pytest - A simple, fast, and fun testing framework for Python

RUN pip install --no-cache-dir poetry pytest
# Set the working directory to /workspace    
WORKDIR /workspace
