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

export GHCUP_TMPDIR=/opt/.ghcup/tmp/
mkdir -p "${GHCUP_TMPDIR}"

set +e
ghcup compile ghc \
  -v "${GHC_VERSION}" \
  -b "${BOOTSTRAP_GHC}" \
  -x "${TARGET}" \
  --isolate "${PREFIX}" \
  --hadrian \
  --flavour=quick-cross \
  -- \
  --with-system-libffi=no \
  --with-ghc-bignum-backend=native \
  --enable-shared \
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
