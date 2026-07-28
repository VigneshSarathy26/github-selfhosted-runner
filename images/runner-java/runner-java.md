# Java Runner Dockerfile

This documentation details the runner-java image Dockerfile, which extends the base runner image with the Java Development Kit (JDK) and build automation tools.

## General Information
- **Repository Path**: [images/runner-java/Dockerfile](file:///D:/repositories/github-selfhosted-runner/images/runner-java/Dockerfile)
- **Status**: Proposed / Placeholder
- **Purpose**: A runner environment configured for compiling, building, testing, and packaging Java-based applications.

## Key Features & Toolchain
- **Inherited Base**: `base-runner` (built from [base/Dockerfile](file:///D:/repositories/github-selfhosted-runner/base/Dockerfile))
- **Additional Utilities**:
  - `JDK` (Java Development Kit, e.g., OpenJDK 17 or 21)
  - `Maven` (Java build and package manager)
  - `Gradle` (Java build automation system)

## Proposed Dockerfile Source Code
*(The repository file is currently empty/under development. Below is the proposed layout to implement these requirements)*

```dockerfile
# Proposed Dockerfile for runner-java
FROM selfhosted-runner-base:latest

USER root

# Install OpenJDK and build utilities
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    maven \
    gradle \
    && rm -rf /var/lib/apt/lists/*

# Set Java Home environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

USER agent
```
