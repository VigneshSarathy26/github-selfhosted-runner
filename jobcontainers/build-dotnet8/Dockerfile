# FROM mcr.microsoft.com/dotnet/sdk:8.0 is used to build the image
FROM mcr.microsoft.com/dotnet/sdk:8.0

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
