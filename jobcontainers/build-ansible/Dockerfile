#   FROM python:3.11-slim is used to build the image
FROM python:3.11-slim
# apt - The Advanced Package Tool, a package manager for Debian and its derivatives
# git - The distributed version control system
# sshpass - 

RUN apt-get update && apt-get install -y --no-install-recommends \
    git sshpass openssh-client curl \
    && rm -rf /var/lib/apt/lists/*
# pip - The package installer for Python
# ansible - Configuration management tool
# ansible-lint - Lint for Ansible playbooks

RUN pip install --no-cache-dir ansible ansible-lint
# Set the working directory to /workspace
WORKDIR /workspace
