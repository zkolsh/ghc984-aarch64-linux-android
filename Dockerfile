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
    cabal-install \
    openjdk-17-jdk \
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

ENV PATH=/opt/android-toolchain/bin:${PATH}
ENV CC=aarch64-linux-android-clang
ENV CXX=aarch64-linux-android-clang++
ENV LD=aarch64-linux-android-ld
ENV AR=aarch64-linux-android-ar
ENV RANLIB=aarch64-linux-android-ranlib
ENV STRIP=aarch64-linux-android-strip

ENV BOOTSTRAP_GHC=9.6.6

RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | \
    BOOTSTRAP_HASKELL_NONINTERACTIVE=1 \
    BOOTSTRAP_HASKELL_GHC_VERSION=${BOOTSTRAP_GHC} \
    BOOTSTRAP_HASKELL_INSTALL_HLS=0 \
    BOOTSTRAP_HASKELL_INSTALL_STACK=0 \
    sh

ENV PATH=/root/.ghcup/bin:${PATH}

RUN cabal update

RUN cabal install \
      alex-3.2.7.1 \
      happy-1.20.1.1 \
      --installdir=/usr/local/bin \
      --overwrite-policy=always

WORKDIR /workspace
