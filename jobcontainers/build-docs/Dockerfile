# FROM python:3.11-slim is used to build the image
FROM python:3.11-slim
# apt - The Advanced Package Tool, a package manager for Debian and its derivatives
# git - The distributed version control system

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# pip - The package installer for Python
# sphinx - Sphinx is a documentation generator for Python
# mkdocs - MkDocs is a static site generator for project documentation

RUN pip install --no-cache-dir sphinx mkdocs
# Set the working directory to /workspace
WORKDIR /workspace
