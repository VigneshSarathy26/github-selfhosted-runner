# Python Data Science & ML Runner Dockerfile

This documentation details the runner-python-datascience image Dockerfile, which extends the base runner image with a complete Data Science, Machine Learning, Deep Learning, and MLOps Python environment.

## General Information
- **Repository Path**: [images/runner-python-datascience/Dockerfile](file:///D:/repositories/github-selfhosted-runner/images/runner-python-datascience/Dockerfile)
- **Status**: Active
- **Purpose**: A specialized Python environment tailored for Data Science analysis, Machine Learning model training, Deep Learning, MLOps pipelines, and model serving.

## Key Features & Toolchain
- **Inherited Base**: `github-runner-ubuntu:1.0.0`
- **Environment Variables**:
  - `TARGETARCH="linux-x64"`
  - `TZ="UTC"`
  - `DEBIAN_FRONTEND="noninteractive"`
  - `PIP_BREAK_SYSTEM_PACKAGES=1`
- **Python Runtime & Core Tools**:
  - Python version specified in `python-version` (e.g., `3.12.0`).
  - Packages installed: `python3.12`, `python3.12-dev`, `python3.12-venv`, `python3-pip`.
  - Configures `/usr/bin/python` via `update-alternatives`.
  - Global tools: `pip`, `setuptools`, `wheel`, `poetry`, `pipenv`, `black`, `flake8`, `pytest`, `mypy`.
- **Data Science & ML Toolchain (via `requirements.txt`)**:
  - **Core Data Science & Analysis**: `numpy`, `pandas`, `scipy`, `matplotlib`, `seaborn`, `plotly`
  - **Machine Learning**: `scikit-learn`, `xgboost`, `lightgbm`, `catboost`
  - **Deep Learning & NLP**: `tensorflow`, `torch`, `torchvision`, `transformers`, `datasets`
  - **MLOps & Hyperparameter Tuning**: `mlflow`, `dvc`, `optuna`, `hyperopt`
  - **Jupyter Environment**: `ipython`, `jupyter`, `notebook`, `jupyterlab`
  - **Model Serving**: `fastapi`, `uvicorn`, `pydantic`
- **Version Management & Wrapper Script**:
  - Dynamically builds `/actions-runner/wrapper.sh` to export dynamic runner labels (`python${PYTHON_VERSION},datascience,ubuntu24`) and execute `/actions-runner/start.sh`.
  - Sets container `ENTRYPOINT` to `/actions-runner/wrapper.sh`.

## Dockerfile Source Code

```dockerfile
# Base image
FROM github-runner-ubuntu:1.0.0

# Set environment variables
ENV TARGETARCH="linux-x64" \
    TZ="UTC" \
    DEBIAN_FRONTEND="noninteractive" \
    PIP_BREAK_SYSTEM_PACKAGES=1

# Copy version configuration
COPY python-version python-version

# Install Python and set alternatives
RUN PYTHON_VERSION=$(cat python-version) \
    && sudo apt-get update \
    && sudo apt-get install -y --no-install-recommends \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python${PYTHON_VERSION}-venv \
    python3-pip \
    && sudo update-alternatives --install /usr/bin/python python /usr/bin/python${PYTHON_VERSION} 1 \
    && sudo rm -rf /var/lib/apt/lists/*

# Install CLI tools & global Python packages
RUN python3 -m pip install --no-cache-dir --upgrade \
    pip \
    setuptools \
    wheel \
    poetry \
    pipenv \
    black \
    flake8 \
    pytest \
    mypy

# Install project dependencies
COPY requirements.txt /tmp/requirements.txt
RUN python3 -m pip install --no-cache-dir -r /tmp/requirements.txt \
    && rm /tmp/requirements.txt

# Create and configure the action runner wrapper script
RUN PYTHON_VERSION=$(cat python-version) \
    && echo "#!/bin/bash" > /actions-runner/wrapper.sh \
    && echo "export RUNNER_LABELS=\"python${PYTHON_VERSION},datascience,ubuntu24\"" >> /actions-runner/wrapper.sh \
    && echo "exec /actions-runner/start.sh" >> /actions-runner/wrapper.sh \
    && sudo chmod +x /actions-runner/wrapper.sh

# Override default entrypoint
ENTRYPOINT ["/actions-runner/wrapper.sh"]
```
