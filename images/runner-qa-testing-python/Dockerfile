# images/runner-python/Dockerfile
ARG BASE_IMAGE=github-runner-base:latest
FROM ${BASE_IMAGE}

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

# Copy requirements file
COPY requirements.txt /tmp/requirements.txt
RUN python3 -m pip install -r /tmp/requirements.txt || true

# Set labels
LABEL runner.type="python" \
    runner.python-version="${PYTHON_VERSION}" \
    runner.version="1.0.0"

ENV RUNNER_LABELS="self-hosted,Linux,X64,python-testing,python,python${PYTHON_VERSION//./}"