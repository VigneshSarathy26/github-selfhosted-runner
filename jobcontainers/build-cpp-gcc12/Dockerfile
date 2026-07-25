# FROM gcc:12 is used to build the image
FROM gcc:12

# apt-get update - Updates the package index
# apt-get install - Installs packages
# cmake - Cross-platform build system generator
# ninja-build - Build system with a focus on speed
# git - The distributed version control system
# rm -rf /var/lib/apt/lists/* - Removes the package index to reduce image size

RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake ninja-build git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
