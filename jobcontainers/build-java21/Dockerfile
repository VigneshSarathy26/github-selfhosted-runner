FROM eclipse-temurin:21-jdk

RUN apt-get update && apt-get install -y --no-install-recommends \
    git maven gradle \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
