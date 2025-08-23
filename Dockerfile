FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ----------------------------
# Install dependencies as root
# ----------------------------
RUN apt-get update && apt-get install -y \
    curl wget unzip zip git gnupg software-properties-common python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------
# Install JDK 17
# ----------------------------
RUN apt-get update && apt-get install -y openjdk-17-jdk && rm -rf /var/lib/apt/lists/*
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# ----------------------------
# Install Maven 3.9.8
# ----------------------------
ARG MAVEN_VERSION=3.9.8
RUN curl -fsSL https://archive.apache.org/dist/maven/maven-3/3.9.8/binaries/apache-maven-3.9.8-bin.tar.gz \
    | tar -xz -C /opt/ \
    && ln -s /opt/apache-maven-${MAVEN_VERSION}/bin/mvn /usr/bin/mvn
ENV MAVEN_HOME=/opt/apache-maven-${MAVEN_VERSION}

# ----------------------------
# Install Node.js 18.20.5 + npm 10.8.2
# ----------------------------
ARG NODE_VERSION=18.20.5
RUN curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz \
    | tar -xJ -C /opt/ \
    && ln -s /opt/node-v${NODE_VERSION}-linux-x64/bin/node /usr/bin/node \
    && ln -s /opt/node-v${NODE_VERSION}-linux-x64/bin/npm /usr/bin/npm
RUN npm install -g npm@10.8.2

# ----------------------------
# Install AWS CLI v2
# ----------------------------
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

# ----------------------------
# Install Anypoint CLI v3.22.7
# ----------------------------
RUN npm install -g anypoint-cli@3.22.7
ENV PATH="/usr/local/bin:$PATH"

# ----------------------------
# Copy Maven settings.xml (root)
# ----------------------------
RUN mkdir -p /root/.m2
COPY ./config/settings.xml /root/.m2/settings.xml

# ----------------------------
# Copy Anypoint CLI config to ~/.anypoint (root)
# ----------------------------
RUN mkdir -p /root/.anypoint
COPY ./config/credentials /root/.anypoint/credentials

# ----------------------------
# Maven local repo (root)
# ----------------------------
RUN mkdir -p /ut01/.m2/repository

# ----------------------------
# Stay as root for runtime
# ----------------------------
WORKDIR /root

# ----------------------------
# Set environment variables for github user
# ----------------------------
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV MAVEN_HOME=/opt/apache-maven-3.9.8
ENV PATH="$JAVA_HOME/bin:$MAVEN_HOME/bin:/opt/node-v18.20.5-linux-x64/bin:/usr/local/bin:$PATH"

# ----------------------------
# Display versions as github user
# ----------------------------
RUN java -version
RUN mvn -v
RUN node -v
RUN npm -v
RUN npm list -g anypoint-cli --depth=0
RUN aws --version
