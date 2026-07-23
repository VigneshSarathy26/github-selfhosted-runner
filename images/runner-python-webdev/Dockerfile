# images/runner-python/Dockerfile
FROM github-runner-ubuntu:1.0.0


# Set environment variables
ENV TARGETARCH="linux-x64" \
    TZ=UTC \
    DEBIAN_FRONTEND=noninteractive \
    RUNNER_LABELS=python-web,python,python${PYTHON_VERSION//./}

# 
ARG PYTHON_VERSION
ENV PYTHON_VERSION=${PYTHON_VERSION}

# Copy version file
COPY .python-version .python-version

# Set Python version from file
RUN export PYTHON_VERSION=$(cat .python-version)

# Install Python and tools
RUN sudo apt-get update && sudo apt-get install -y \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python${PYTHON_VERSION}-venv \
    python3-pip \
    && sudo rm -rf /var/lib/apt/lists/*

# Update alternatives to make python3 default
RUN sudo update-alternatives --install /usr/bin/python python /usr/bin/python${PYTHON_VERSION} 1

# Install Python package managers
RUN python3 -m pip install --upgrade \
    pip \
    setuptools \
    wheel \
    poetry \
    pipenv \
    black \
    flake8 \
    pytest \
    mypy

