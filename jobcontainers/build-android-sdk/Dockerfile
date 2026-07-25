# FROM eclipse-temurin:17-jdk is used to build the image
FROM eclipse-temurin:17-jdk
# ENV ANDROID_SDK_ROOT=/opt/android-sdk is used to set the environment variable ANDROID_SDK_ROOT to /opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk
# Debuf info 
# apt-get update - Updates the package index
# apt-get install - Installs packages
# git - The distributed version control system
# curl - Transfers a URL
# unzip - Uncompresses zipped files
# gradle - Build automation tool
# rm -rf /var/lib/apt/lists/* - Removes the package index to reduce image size

RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl unzip gradle \
    && rm -rf /var/lib/apt/lists/*
# WORKDIR /workspace is used to set the working directory to /workspace
WORKDIR /workspace