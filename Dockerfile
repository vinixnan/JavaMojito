FROM debian:12-slim AS base

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/opt/jdk
ENV PATH=$JAVA_HOME/bin:$PATH
ARG JDK_VERSION=21
ARG JDK_BUILD=35
ARG MAVEN_VERSION=3.9.9
ARG YQ_VERSION=v4.2.0

RUN apt-get update -q && apt install -q git wget gcc g++ gfortran libopenblas-dev liblapack-dev pkg-config ninja-build patchelf rename linux-perf nano build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev wget curl build-essential cmake libboost-context-dev libboost-program-options-dev libboost-filesystem-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev libharfbuzz-dev libfribidi-dev libxcb1-dev -y

WORKDIR /opt

RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    if [ "$ARCH" = "amd64" ]; then \
        JDK_ARCH="x64"; \
    elif [ "$ARCH" = "arm64" ]; then \
        JDK_ARCH="aarch64"; \
    else \
        echo "Unsupported architecture: $ARCH"; \
        exit 1; \
    fi; \
    wget -q https://download.oracle.com/java/${JDK_VERSION}/latest/jdk-${JDK_VERSION}_linux-${JDK_ARCH}_bin.tar.gz; \
    tar -xzf jdk-${JDK_VERSION}_linux-${JDK_ARCH}_bin.tar.gz; \
    rm jdk-${JDK_VERSION}_linux-${JDK_ARCH}_bin.tar.gz; \
    mv jdk-${JDK_VERSION}* $JAVA_HOME

RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    if [ "$ARCH" = "amd64" ]; then \
        PLATFORM="linux_amd64"; \
    elif [ "$ARCH" = "arm64" ]; then \
        PLATFORM="linux_arm64"; \
    else \
        echo "Unsupported architecture: $ARCH"; \
        exit 1; \
    fi; \
    wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_${PLATFORM}.tar.gz -O - |\
    tar xz && mv yq_${PLATFORM} /usr/local/bin/yq    


RUN wget -q https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    tar -xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    mv apache-maven-${MAVEN_VERSION} /opt/maven && \
    ln -s /opt/maven/bin/mvn /usr/bin/mvn && \
    rm apache-maven-${MAVEN_VERSION}-bin.tar.gz

    RUN rm -rf /var/lib/apt/lists/*

RUN java -version
RUN mvn --version
RUN perf --version
RUN yq --version

FROM base AS mojito

WORKDIR /opt

RUN git clone https://gitlab.irit.fr/sepia-pub/mojitos.git

WORKDIR /opt/mojitos

RUN ./configure && make && make install

RUN which mojitos || true

RUN mojitos -t 2 -f 2 -r