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
ENV GHC_PREFIX=/opt/ghc-${BOOTSTRAP_GHC}

RUN curl -L https://downloads.haskell.org/~ghc/${BOOTSTRAP_GHC}/ghc-${BOOTSTRAP_GHC}-x86_64-deb10-linux.tar.xz \
    -o /tmp/ghc.tar.xz && \
    mkdir -p /tmp/ghc-src && \
    tar -xf /tmp/ghc.tar.xz -C /tmp/ghc-src --strip-components=1 && \
    cd /tmp/ghc-src && \
    ./configure --prefix=${GHC_PREFIX} && \
    make install && \
    rm -rf /tmp/ghc-src /tmp/ghc.tar.xz

ENV PATH=${GHC_PREFIX}/bin:${PATH}

RUN cabal update

RUN cabal install \
      alex-3.2.7.1 \
      happy-1.20.1.1 \
      --installdir=/usr/local/bin \
      --overwrite-policy=always

WORKDIR /workspace
