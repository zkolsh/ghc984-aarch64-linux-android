#!/usr/bin/env bash
set -euo pipefail

GHC_VERSION=9.8.4
TARGET=aarch64-unknown-linux-android
ANDROID_API=21

export ANDROID_NDK_ROOT=/opt/android-ndk
export ANDROID_TOOLCHAIN=/opt/android-toolchain
export PATH=/opt/android-toolchain/bin:${PATH}
export CC=aarch64-linux-android21-clang
export CXX=aarch64-linux-android21-clang++
export LD=$CC
export AR=llvm-ar
export NM=$(which llvm-nm)
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

./boot
./configure \
    --target=$TARGET \
    --with-intree-gmp \
    --with-system-libffi \
    --enable-unregisterised \
    --with-gcc="$CC" \
    CC="$CC" \
    CXX="$CXX" \
    LD="$LD" \
    AR="$AR" \
    RANLIB="$RANLIB" \
    NM="$(which llvm-nm)" \
    STRIP="$STRIP" \
    --with-iconv-includes="$ANDROID_TOOLCHAIN/include" \
    --with-iconv-libraries="$ANDROID_TOOLCHAIN/lib" \
    --with-system-libffi-includes="$ANDROID_TOOLCHAIN/include" \
    --with-system-libffi-libraries="$ANDROID_TOOLCHAIN/lib" \

hadrian/build \
  --build-root=_build \
  --flavour=quick-cross \
  "*.capstone.configure=--host=$TARGET" \
  "*.gmp.configure=--host=$TARGET" \
  "stage1.*.ghc.link.opts=-optl-static" \
  binary-dist

echo
echo "Bindist located at:"
ls -lh _build/bindist
