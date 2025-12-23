#!/usr/bin/env bash
set -euo pipefail

GHC_VERSION=9.8.4
TARGET=aarch64-unknown-linux-android
ANDROID_API=21

export PATH=/opt/android-toolchain/bin:${PATH}
export CC=aarch64-linux-android21-clang
export CXX=aarch64-linux-android21-clang++
export LD=$CC
export AR=llvm-ar
export RANLIB=llvm-ranlib
export STRIP=aarch64-linux-android-strip

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

if [ ! -d ghc ]; then
  git clone --branch ghc-${GHC_VERSION}-release \
    --depth 1 https://gitlab.haskell.org/ghc/ghc.git
fi

cd ghc
git submodule update --init --recursive

export ANDROID_NDK_ROOT=/opt/android-ndk
export ANDROID_TOOLCHAIN=/opt/android-toolchain

./boot
./configure \
  --target=${TARGET} \
  --with-intree-gmp \
  --with-system-libffi \
  --enable-unregisterised \
  --with-clang=$CC \
  --with-ld=$LD \
  --with-nm=$(which llvm-nm) \
  --with-ar=$AR \
  --with-ranlib=$RANLIB \
  --with-strip=$STRIP

hadrian/build \
  --build-root=_build \
  --flavour=quick-cross \
  binary-dist

echo
echo "Bindist located at:"
ls -lh _build/bindist
