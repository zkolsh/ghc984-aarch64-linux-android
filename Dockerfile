FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_API=35
ENV TARGET=aarch64-linux-android

RUN apt-get update && apt-get install -y \
    build-essential autoconf automake libtool \
    curl git python3 gperf \
    llvm-15 clang \
    xz-utils ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /ndk && \
    curl -L https://dl.google.com/android/repository/android-ndk-r26d-linux.zip \
    -o /ndk/ndk.zip && \
    apt-get update && apt-get install -y unzip && \
    unzip /ndk/ndk.zip -d /ndk && \
    mv /ndk/android-ndk-r26d /android-ndk && \
    rm -rf /ndk

ENV ANDROID_NDK_HOME=/android-ndk
ENV PATH=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH

RUN mkdir -p /opt/ghc-src && \
    curl -L https://downloads.haskell.org/ghc/9.8.4/ghc-9.8.4-x86_64-deb11-linux.tar.xz \
    | tar -xJ -C /opt/ghc-src --strip-components=1 && \
    cd /opt/ghc-src && \
    ./configure --prefix=/opt/ghc && \
    make install

ENV PATH=/opt/ghc/bin:$PATH

WORKDIR /build
