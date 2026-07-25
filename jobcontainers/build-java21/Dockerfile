# FROM eclipse-temurin:21-jdk is used to build the image
FROM eclipse-temurin:21-jdk

# RUN apt-get update && apt-get install -y --no-install-recommends \
#     git maven gradle \
#     && rm -rf /var/lib/apt/lists/*
# git - The distributed version control system
# maven - Apache Maven is a build automation tool used primarily for Java projects
# gradle - Gradle is a build automation tool for Java

RUN apt-get update && apt-get install -y --no-install-recommends \
    git maven gradle \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory to /workspace
WORKDIR /workspace
