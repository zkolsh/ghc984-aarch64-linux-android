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
export LD=ld.ldd
export AR=llvm-ar
export NM=$(which llvm-nm)
export RANLIB=llvm-ranlib
export STRIP=aarch64-linux-android-strip

export CC_FOR_BUILD=gcc
export CXX_FOR_BUILD=g++
export LD_FOR_BUILD=ld
export AR_FOR_BUILD=ar
export RANLIB_FOR_BUILD=ranlib

export LLVM_CONFIG=llvm-config
export LLC=clang
export OPT=clang

export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export CFLAGS="--sysroot=${ANDROID_TOOLCHAIN}/sysroot"
export LDFLAGS="--sysroot=${ANDROID_TOOLCHAIN}/sysroot"

export ac_cv_func_setenv=yes
export ac_cv_func_putenv=yes
export ac_cv_func_unsetenv=yes
export ac_cv_lib_ffi_ffi_call=no

export GHCUP_TMPDIR=/opt/.ghcup/logs/
mkdir -p "${GHCUP_TMPDIR}"

set +e
ghcup compile ghc \
  -v "${GHC_VERSION}" \
  -b "${BOOTSTRAP_GHC}" \
  -x "${TARGET}" \
  --isolate "${PREFIX}" \
  --hadrian \
  --flavour=quick-cross+native_bignum \
  -- \
  --hadrian-args="--disable-ghci --disable-interpreter" \
  --verbose

rc=$?
set -e

if [ $rc -ne 0 ]; then
  echo ">>> Build failed"
  echo "Hadrian logs:"
  find "${GHCUP_TMPDIR}" -name hadrian.log -print -exec tail -n 400 {} \; || true

  echo
  echo "*.log:"
  find "${GHCUP_TMPDIR}" -name "*.log" -print -exec tail -n 400 {} \; || true

  echo
  echo "Directory tree:"
  find "${GHCUP_TMPDIR}" -maxdepth 4 -type d || true

  exit $rc
fi

tar -C ${PREFIX} -cJf ${TARBALL} .

echo
echo "Bindist located at:"
ls -lh _build/bindist
