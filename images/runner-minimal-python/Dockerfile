# images/runner-python/Dockerfile
# Build with: docker build --pull --rm -f "Dockerfile" -t "githubselfhostedrunner:latest" "."
FROM mailtovignesh/github-selfhosted-runner:latest
ARG PYTHON_VERSION
ENV PYTHON_VERSION=${PYTHON_VERSION}

# Copy version file
COPY .python-version .python-version

# Install Python and tools using version from file
RUN export PYTHON_VERSION=$(cat .python-version) \
    && sudo apt-get update && sudo apt-get install -y \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python${PYTHON_VERSION}-venv \
    python3-pip \
    && sudo rm -rf /var/lib/apt/lists/*

# Update alternatives to make python3 default
RUN export PYTHON_VERSION=$(cat .python-version) \
    && sudo update-alternatives --install /usr/bin/python python /usr/bin/python${PYTHON_VERSION} 1

# Install Python package managers
# ✅ Fix for PEP 668
ENV PIP_BREAK_SYSTEM_PACKAGES=1

# Now pip works normally
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
RUN python3 -m pip install --upgrade pip \
    && python3 -m pip install --no-cache-dir -r /tmp/requirements.txt

# Set labels
LABEL runner.type="python" \
    runner.python-version="${PYTHON_VERSION}" \
    runner.version="1.0.0"

ENV RUNNER_LABELS="self-hosted,Linux,X64,python,minimal,python-${PYTHON_VERSION}"
