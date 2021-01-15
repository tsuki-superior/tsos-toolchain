#!/usr/bin/env bash

#Remove previous installation
rm -rfv /usr/tsos-toolchain

#The version of gcc that will be used here
GCC_VERSION=10.2.0

#The version of binutils that will be used here
BINUTILS_VERSION=2.35

#The version of devkitarm that will be used here
DEVKITARM_VERSION=r55

#The version of gbdk to use
GBDK_VERSION=4.0.1

#The url for gcc`s tarball
GCC_DOWNLOAD_URL=https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.xz

#The url for binutils`s tarball
BINUTILS_DOWNLOAD_URL=https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.xz

#The url for devkitarms`s tarball
DEVKITARM_DOWNLOAD_URL=https://github.com/devkitPro/buildscripts/archive/devkitARM_$DEVKITARM_VERSION.tar.gz

#The url for gbdk
GBDK_DOWNLOAD_URL=https://github.com/Zal0/gbdk-2020/archive/$GBDK_VERSION.tar.gz

#The install dir for the compilers
INSTALL_DIR=/usr/i686-elf

#Prepare and move to the directory
rm -rfv /tmp/tsos
mkdir -pv /tmp/tsos
cd /tmp/tsos

#Get the compilers from the web
wget $GCC_DOWNLOAD_URL
wget $BINUTILS_DOWNLOAD_URL
wget $DEVKITARM_DOWNLOAD_URL
wget $GBDK_DOWNLOAD_URL

#Unarchive those tarballs
tar -xf gcc-$GCC_VERSION.tar.xz
mv -v gcc-$GCC_VERSION/ gcc/
tar -xf binutils-$BINUTILS_VERSION.tar.xz
mv -v binutils-$BINUTILS_VERSION/ binutils/
tar -xf buildscripts-devkitARM_$DEVKITARM_VERSION.tar.gz
mv -v buildscripts-devkitARM_$DEVKITARM_VERSION/ devkitarm
tar -xf gbdk-2020-$GBDK_VERSION.tar.gz
mv -v gbdk-2020-$GBDK_VERSION/ gbdk

#We will compile binutils first
cd binutils
mkdir -pv build
cd build
../configure --prefix=$INSTALL_DIR \
    --enable-gold \
    --enable-interwork \
    --target=i686-elf \
    --enable-multilib \
    --disable-nls \
    --disable-werror

make
make install

#Now we will compile gcc
cd /tmp/tsos
cd gcc
mkdir -pv build
cd build
../configure --prefix=$INSTALL_DIR \
    --enable-languages=c,c++ \
    --disable-libssp \
    --disable-nls \
    --disable-libssp \
    --disable-werror

make
make install

#Install devkitarm
cd /tmp/tsos
cd devkitarm
chmod +x ./*.sh
./build-devkit.sh

#Install gbdk
cd /tmp/tsos
cd gbdk
make 
make install

#Lets update that path variable
PATH=$PATH:$INSTALL_DIR/bin

echo "export PATH=$PATH" >>~/.bashrc

cd $CODE_DIR
