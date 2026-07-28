# Python Web Development Runner Dockerfile

This documentation details the runner-python-webdev image Dockerfile, which extends the base runner image with a comprehensive Python web application development, API creation, database ORM, background task queue, and web testing toolchain.

## General Information
- **Repository Path**: [images/runner-python-webdev/Dockerfile](file:///D:/repositories/github-selfhosted-runner/images/runner-python-webdev/Dockerfile)
- **Status**: Active
- **Purpose**: A specialized Python runner environment designed for building, testing, and running web applications, REST/GraphQL APIs, database migrations, and background worker queues.

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
- **Web Development Toolchain (via `requirements.txt`)**:
  - **Web Frameworks**: `Django`, `Flask`, `FastAPI`, `Sanic`, `Tornado`
  - **API Building & Schema Utilities**: `djangorestframework`, `drf-yasg` (OpenAPI/Swagger generator), `marshmallow`, `webargs`, `apispec`
  - **Database Drivers & ORMs**: `SQLAlchemy`, `Alembic` (Database migrations), `psycopg2-binary` (PostgreSQL), `asyncpg`, `aiomysql`, `pymongo`, `redis`
  - **Authentication & Security**: `python-jose[cryptography]`, `PyJWT`, `passlib`, `bcrypt`, `oauthlib`
  - **Task Queues & Asynchronous Workers**: `Celery`, `rq`, `dramatiq`
  - **Web Testing & Data Mocking**: `pytest-django`, `pytest-flask`, `pytest-asyncio`, `pytest-cov`, `factory-boy`, `faker`
  - **Utilities**: `python-multipart`, `python-dateutil`, `Pillow`, `email-validator`
- **Version Management & Wrapper Script**:
  - Dynamically builds `/actions-runner/wrapper.sh` to export dynamic runner labels (`python${PYTHON_VERSION},webdev,ubuntu24`) and execute `/actions-runner/start.sh`.
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
    && echo "export RUNNER_LABELS=\"python${PYTHON_VERSION},webdev,ubuntu24\"" >> /actions-runner/wrapper.sh \
    && echo "exec /actions-runner/start.sh" >> /actions-runner/wrapper.sh \
    && sudo chmod +x /actions-runner/wrapper.sh

# Override default entrypoint
ENTRYPOINT ["/actions-runner/wrapper.sh"]
```
