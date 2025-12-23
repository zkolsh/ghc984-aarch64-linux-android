#!/usr/bin/env bash
set -eux

PREFIX=/opt/android-bridge
TARGET=aarch64-linux-android
API=21
CC=${TARGET}${API}-clang

curl -LO https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.17.tar.gz
tar -xzf libiconv-1.17.tar.gz
cd libiconv-1.17
./configure --host=$TARGET --prefix=$PREFIX --disable-shared --enable-static CC=$CC
make -j$(nproc)
make install
cd ..

curl -LO https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.4.tar.gz
tar -xzf ncurses-6.4.tar.gz
cd ncurses-6.4
./configure \
  --host=$TARGET \
  --prefix=$PREFIX \
  --with-shared=no \
  --without-debug \
  --without-ada \
  --without-cxx-binding \
  --enable-widec \
  --disable-stripping \
  --without-progs \
  CC=$CC
make -j$(nproc)
make install
cd ..

git clone --recursive -b ghc-9.8.4-release https://github.com/ghc/ghc.git ghc
cd ghc

./boot
./configure \
  --target=$TARGET \
  --with-intree-gmp \
  --with-system-libffi=no \
  --with-iconv-includes=$PREFIX/include \
  --with-iconv-libraries=$PREFIX/lib \
  --with-curses-includes=$PREFIX/include \
  --with-curses-libraries=$PREFIX/lib \
  --with-clang=$(which clang) \
  --with-ar=llvm-ar \
  --with-nm=llvm-nm \
  --with-ranlib=llvm-ranlib \
  CONF_CC_OPTS_STAGE2="-I$PREFIX/include" \
  CONF_GCC_LINKER_OPTS_STAGE2="-L$PREFIX/lib"

hadrian/build -j$(nproc) --flavour=quick-cross binary-dist
