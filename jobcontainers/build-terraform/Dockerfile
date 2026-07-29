# FROM hashicorp/terraform:1.8 is used to build the image.
FROM hashicorp/terraform:1.8
# apk add --no-cache curl unzip python3 py3-pip git bash installs the following packages
# curl - Transfer a URL
# unzip - Unarchiver for ZIP files
# python3 - Python 3 interpreter
# py3-pip - Python 3 package installer
# git - The distributed version control system
# bash - GNU Bash Shell
RUN apk add --no-cache curl unzip python3 py3-pip git bash
# Set the working directory to /workspace
WORKDIR /workspace
