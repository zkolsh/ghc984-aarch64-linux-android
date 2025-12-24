FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_NDK_ROOT=/opt/android-ndk
ENV ANDROID_API=21
ENV NDK_VERSION=29.0.14206865

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    python3 \
    python3-pip \
    libgmp-dev \
    libncurses-dev \
    libtinfo-dev \
    libffi-dev \
    libnuma-dev \
    zlib1g-dev \
    ca-certificates \
    xz-utils \
    unzip \
    autoconf \
    automake \
    libtool \
    pkg-config \
    openjdk-17-jdk \
    llvm \
    llvm-dev \
    clang \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=${JAVA_HOME}/bin:${PATH}

RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    curl -L https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip \
      -o /tmp/cmdline-tools.zip && \
    unzip /tmp/cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools \
       ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip

ENV PATH=${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${PATH}

RUN yes | sdkmanager --licenses && \
    sdkmanager \
      "platform-tools" \
      "platforms;android-${ANDROID_API}" \
      "ndk;${NDK_VERSION}"

RUN ln -s ${ANDROID_SDK_ROOT}/ndk/${NDK_VERSION} ${ANDROID_NDK_ROOT}

RUN ${ANDROID_NDK_ROOT}/build/tools/make_standalone_toolchain.py \
      --arch arm64 \
      --api ${ANDROID_API} \
      --install-dir /opt/android-toolchain

ENV GHCUP_INSTALL_BASE_PREFIX=/opt
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | \
    BOOTSTRAP_HASKELL_NONINTERACTIVE=1 \
    BOOTSTRAP_HASKELL_GHC_VERSION=9.6.6 \
    BOOTSTRAP_HASKELL_CABAL_VERSION=latest \
    sh

ENV PATH=/opt/.ghcup/bin:${PATH}

WORKDIR /workspace
