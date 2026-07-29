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