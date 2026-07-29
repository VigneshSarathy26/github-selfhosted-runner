# Python Scientific Computing & Research Runner Dockerfile

This documentation details the runner-python-scientific-computing image Dockerfile, which extends the base runner image with a comprehensive Python scientific computing, research, image processing, geospatial analysis, astronomy, and bioinformatics toolchain.

## General Information
- **Repository Path**: [images/runner-python-scientific-computing/Dockerfile](file:///D:/repositories/github-selfhosted-runner/images/runner-python-scientific-computing/Dockerfile)
- **Status**: Active
- **Purpose**: A specialized Python runner environment designed for scientific research, numerical simulations, data visualization, signal/image processing, statistical modeling, geospatial data processing, astronomy, and bioinformatics workflows.

## Key Features & Toolchain
- **Inherited Base**: `github-runner-ubuntu:1.0.0`
- **Environment Variables**:
  - `TARGETARCH="linux-x64"`
  - `TZ="UTC"`
  - `DEBIAN_FRONTEND="noninteractive"`
  - `PIP_BREAK_SYSTEM_PACKAGES=1`
- **Python Runtime & Global Tools**:
  - Configurable Python version specified in `python-version` (e.g., `3.12.0`).
  - Packages installed: `python3.12`, `python3.12-dev`, `python3.12-venv`, `python3-pip`.
  - Configures `/usr/bin/python` via `update-alternatives`.
  - Global tools: `pip`, `setuptools`, `wheel`, `poetry`, `pipenv`, `black`, `flake8`, `pytest`, `mypy`.
- **Scientific Toolchain (via `requirements.txt`)**:
  - **Core Scientific Computing & Data Formats**: `numpy`, `scipy`, `pandas`, `xarray`, `netCDF4`, `h5py`
  - **Data Visualization**: `matplotlib`, `seaborn`, `plotly`, `bokeh`, `holoviews`
  - **Signal & Image Processing**: `scikit-image`, `opencv-python`, `Pillow`, `imageio`
  - **Statistical & Bayesian Modeling**: `statsmodels`, `scikit-learn`, `pymc`, `arviz`
  - **Geospatial & Remote Sensing**: `geopandas`, `shapely`, `fiona`, `pyproj`, `rasterio`
  - **Astronomy & Astrophysics**: `astropy`, `sunpy`, `astroquery`
  - **Bioinformatics & Life Sciences**: `biopython`
- **Version Management & Wrapper Script**:
  - Dynamically builds `/actions-runner/wrapper.sh` to export dynamic runner labels (`python${PYTHON_VERSION},scientific,computing,ubuntu24`) and execute `/actions-runner/start.sh`.
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
    && echo "export RUNNER_LABELS=\"python${PYTHON_VERSION},scientific,computing,ubuntu24\"" >> /actions-runner/wrapper.sh \
    && echo "exec /actions-runner/start.sh" >> /actions-runner/wrapper.sh \
    && sudo chmod +x /actions-runner/wrapper.sh

# Override default entrypoint
ENTRYPOINT ["/actions-runner/wrapper.sh"]
```
