#!/bin/bash

#Remove previous installation
rm -rfv /usr/tsos-toolchain

#The version of gcc that will be used here
GCC_VERSION=10.2.0

#The version of binutils that will be used here
BINUTILS_VERSION=2.35.1

#The version of devkitarm that will be used here
DEVKITARM_VERSION=r55

#The version of gbdk to use
GBDK_VERSION=4.0.2

#The version of sdcc to use
SDCC_VERSION=4.0.0

#The url for gcc`s tarball
GCC_DOWNLOAD_URL=https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.xz

#The url for binutils`s tarball
BINUTILS_DOWNLOAD_URL=https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.xz

#The url for devkitarms`s tarball
DEVKITARM_DOWNLOAD_URL=https://github.com/devkitPro/buildscripts/archive/devkitARM_$DEVKITARM_VERSION.tar.gz

#The sdcc download url
SDCC_DOWNLOAD_URL=https://netactuate.dl.sourceforge.net/project/sdcc/sdcc/$SDCC_VERSION/sdcc-src-$SDCC_VERSION.tar.bz2

#The url for gbdk
GBDK_DOWNLOAD_URL=https://github.com/Zal0/gbdk-2020/archive/$GBDK_VERSION.tar.gz

#Prepare and move to the directory
rm -rfv /tmp/tsos
mkdir -pv /tmp/tsos
cd /tmp/tsos

#Get the compilers from the web
wget $GCC_DOWNLOAD_URL
wget $BINUTILS_DOWNLOAD_URL
#wget $DEVKITARM_DOWNLOAD_URL
#wget $SDCC_DOWNLOAD_URL
#wget $GBDK_DOWNLOAD_URL

#Unarchive those tarballs
tar -xf gcc-$GCC_VERSION.tar.xz
mv -v gcc-$GCC_VERSION/ gcc/
tar -xf binutils-$BINUTILS_VERSION.tar.xz
mv -v binutils-$BINUTILS_VERSION/ binutils/
#tar -xf devkitARM_$DEVKITARM_VERSION.tar.gz
#mv -v buildscripts-devkitARM_$DEVKITARM_VERSION/ devkitarm
#tar -xf sdcc-src-$SDCC_VERSION.tar.bz2
#mv -v sdcc-src-$SDCC_VERSION/ sdcc
#tar -xf $GBDK_VERSION.tar.gz
#mv -v gbdk-2020-$GBDK_VERSION/ gbdk

#Lets update that path variable
export PATH=$PATH:$INSTALL_DIR/bin
echo "export PATH=$PATH" >>~/.bashrc

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

make -j$(nproc)
make install
rm -rfv /tmp/tsos/binutils

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
    --disable-werror \
    --without-headers


make -j$(nproc)
make install
rm -rfv /tmp/tsos/gcc

#Im sorry that stuff doesnt work rn
exit

#Install devkitarm
cd /tmp/tsos
cd devkitarm
chmod +x ./*.sh
./build-devkit.sh 1

#Install sdcc
cd /tmp/tsos
cd sdcc
mkdir -pv build
cd build
../configure --prefix=$INSTALL_DIR

export SDCCDIR=$INSTALL_DIR

#Install gbdk
cd /tmp/tsos
cd gbdk
make 
make install

echo "export PATH=$PATH" >>~/.bashrc

cd $CODE_DIR
