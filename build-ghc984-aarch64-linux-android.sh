#!/usr/bin/env bash
set -euo pipefail

GHC_VERSION=9.8.4
BOOTSTRAP_GHC=9.6.6
TARGET=aarch64-linux-android
ANDROID_API=21
PREFIX=/opt/ghc-${GHC_VERSION}-linux-android
TARBALL=/workspace/ghc-${GHC_VERSION}-linux-android-aarch64.tar.xz

export ANDROID_NDK_ROOT=/opt/android-ndk
export ANDROID_TOOLCHAIN=/opt/android-toolchain
export PATH=/opt/android-toolchain/bin:${PATH}
export CC=aarch64-linux-android${ANDROID_API}-clang
export CXX=aarch64-linux-android${ANDROID_API}-clang++
export LD=$CC
export AR=llvm-ar
export NM=$(which llvm-nm)
export RANLIB=llvm-ranlib
export STRIP=aarch64-linux-android-strip

export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export CFLAGS="--sysroot=${ANDROID_TOOLCHAIN}/sysroot"
export LDFLAGS="--sysroot=${ANDROID_TOOLCHAIN}/sysroot"

ghcup compile ghc \
  -v ${GHC_VERSION} \
  -b ${BOOTSTRAP_GHC} \
  -x ${TARGET} \
  --isolate ${PREFIX} \
  --hadrian \
  --flavour=quick-cross \
  -- \
  --with-system-libffi \
  --with-ghc-bignum-backend=native \
  --enable-shared \
  --disable-static

tar -C ${PREFIX} -cJf ${TARBALL} .

echo
echo "Bindist located at:"
ls -lh _build/bindist
