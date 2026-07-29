# Java Runner Dockerfile

This documentation details the runner-java image Dockerfile, which extends the base runner image with the Java Development Kit (JDK) and build automation tools (Maven and Gradle).

## General Information
- **Repository Path**: [images/runner-java/Dockerfile](file:///D:/repositories/github-selfhosted-runner/images/runner-java/Dockerfile)
- **Status**: Active
- **Purpose**: A runner environment configured for compiling, building, testing, and packaging Java-based applications.

## Key Features & Toolchain
- **Inherited Base**: `github-runner-ubuntu:1.0.0`
- **Environment Variables**:
  - `JAVA_HOME=/opt/java`
  - `MAVEN_HOME=/opt/maven`
  - `GRADLE_HOME=/opt/gradle`
  - `PATH=${GRADLE_HOME}/bin:${MAVEN_HOME}/bin:${JAVA_HOME}/bin:${PATH}`
- **Version Management & Tools**:
  - Reads target versions dynamically from version files (`java-version`, `maven-version`, `gradle-version`).
  - Installs OpenJDK (`openjdk-${JAVA_VER}-jdk`) and links `/usr/lib/jvm/java-${JAVA_VER}-openjdk-amd64` to `/opt/java`.
  - Downloads and extracts Apache Maven binary tarball from official archives to `/opt/maven`.
  - Downloads and extracts Gradle distribution zip from official services to `/opt/gradle`.
  - Verifies installations by executing `java -version`, `mvn -version`, and `gradle -version`.

## Dockerfile Source Code

```dockerfile
FROM github-runner-ubuntu:1.0.0

WORKDIR /tmp/build
COPY *-version .

ENV DEBIAN_FRONTEND=noninteractive

# Install prerequisites
RUN sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends \
    wget \
    curl \
    ca-certificates \
    gnupg \
    unzip \
    && sudo rm -rf /var/lib/apt/lists/*

# Install JDK
RUN JAVA_VER=$(cat java-version) && \
    sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends \
    openjdk-${JAVA_VER}-jdk \
    && sudo rm -rf /var/lib/apt/lists/* && \
    sudo ln -s /usr/lib/jvm/java-${JAVA_VER}-openjdk-amd64 /opt/java

ENV JAVA_HOME=/opt/java
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Install Maven (specific version via tarball)
RUN MVN_VER=$(cat maven-version) && \
    wget -q "https://archive.apache.org/dist/maven/maven-3/${MVN_VER}/binaries/apache-maven-${MVN_VER}-bin.tar.gz" -O /tmp/maven.tar.gz && \
    sudo mkdir -p /opt/maven && \
    sudo tar -xzf /tmp/maven.tar.gz -C /opt/maven --strip-components=1 && \
    rm /tmp/maven.tar.gz

ENV MAVEN_HOME=/opt/maven
ENV PATH="${MAVEN_HOME}/bin:${PATH}"

# Install Gradle (specific version via zip)
RUN GRADLE_VER=$(cat gradle-version) && \
    sudo mkdir -p /opt/gradle && \
    wget -q "https://services.gradle.org/distributions/gradle-${GRADLE_VER}-bin.zip" -O /tmp/gradle.zip && \
    unzip -q /tmp/gradle.zip -d /tmp/gradle-tmp && \
    sudo mv /tmp/gradle-tmp/gradle-${GRADLE_VER}/* /opt/gradle/ && \
    rm -rf /tmp/gradle.zip /tmp/gradle-tmp

ENV GRADLE_HOME=/opt/gradle
ENV PATH="${GRADLE_HOME}/bin:${PATH}"

# Verify installations
RUN java -version && mvn -version && gradle -version

WORKDIR /
```
