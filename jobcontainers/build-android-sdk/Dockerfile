FROM eclipse-temurin:17-jdk

ENV ANDROID_SDK_ROOT=/opt/android-sdk

RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl unzip gradle \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
