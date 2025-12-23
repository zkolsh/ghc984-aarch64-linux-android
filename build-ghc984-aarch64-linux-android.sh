#!/usr/bin/env bash
set -euo pipefail

GHC_VERSION=9.8.4
TARGET=aarch64-linux-android
ANDROID_API=21

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

if [ ! -d ghc ]; then
  git clone --branch ghc-${GHC_VERSION}-release \
    --depth 1 https://gitlab.haskell.org/ghc/ghc.git
fi

cd ghc
git submodule update --init --recursive

cat > hadrian/settings.cabal <<EOF
build-tool-depends:
  alex:alex == 3.2.7.1,
  happy:happy == 1.20.1.1
EOF

cat > mk/build.mk <<EOF
BuildFlavour = quick-cross

SRC_HC_OPTS += -O0
GhcLibHcOpts += -O0

Stage1Only = YES
HADRIAN_ARGS += --docs=no-sphinx
EOF

export ANDROID_NDK_ROOT=/opt/android-ndk
export ANDROID_TOOLCHAIN=/opt/android-toolchain

export CC=aarch64-linux-android-clang
export CXX=aarch64-linux-android-clang++
export LD=aarch64-linux-android-ld
export AR=aarch64-linux-android-ar
export RANLIB=aarch64-linux-android-ranlib
export STRIP=aarch64-linux-android-strip

./boot
./configure \
  --target=${TARGET} \
  --with-gmp \
  --disable-numa \
  --enable-unregisterised \
  --enable-shared \
  --enable-dynamic \
  --with-iconv=no

hadrian/build \
  --flavour=quick-cross \
  --build-root=_build \
  binary-dist

echo
echo "Bindist located at:"
ls -lh _build/bindist
