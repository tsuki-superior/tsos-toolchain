#!/bin/bash

#TS/OS toolchain location
TSOS_TOOLCHAIN=/usr/tsos-toolchain

#Remove previous installation
rm -rfv $TSOS_TOOLCHAIN

#Add new one
mkdir -pv $TSOS_TOOLCHAIN/tools

#The version of gcc that will be used here
GCC_VERSION=10.1.0

#The version of binutils that will be used here
BINUTILS_VERSION=2.35

#The version of gbdk to use
GBDK_VERSION=4.0.2

#The version of sdcc to use
SDCC_VERSION=4.0.0

#The url for gcc`s tarball
GCC_DOWNLOAD_URL=https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.xz

#The url for binutils`s tarball
BINUTILS_DOWNLOAD_URL=https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.xz

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
#wget $SDCC_DOWNLOAD_URL
#wget $GBDK_DOWNLOAD_URL

#Unarchive those tarballs
tar -xf gcc-$GCC_VERSION.tar.xz
mv -v gcc-$GCC_VERSION/ gcc-x86/
cp -Rv gcc-x86/ gcc-arm/

tar -xf binutils-$BINUTILS_VERSION.tar.xz
mv -v binutils-$BINUTILS_VERSION/ binutils-x86/
cp -Rv binutils-x86/ binutils-arm/

#tar -xf sdcc-src-$SDCC_VERSION.tar.bz2
#mv -v sdcc-src-$SDCC_VERSION/ sdcc

#tar -xf $GBDK_VERSION.tar.gz
#mv -v gbdk-2020-$GBDK_VERSION/ gbdk

#Lets update that path variable
export PATH=$PATH:$TSOS_TOOLCHAIN/bin
echo "export PATH=$PATH" >>~/.bashrc

#We will compile binutils first for x86
cd binutils-x86
mkdir -pv build
cd build
../configure --prefix=$TSOS_TOOLCHAIN \
    --enable-gold \
    --enable-interwork \
    --target=i686-elf \
    --enable-multilib \
    --disable-nls \
    --disable-werror

make -j$(nproc)
make install
rm -rf /tmp/tsos/binutils-x86

#Now we will compile gcc for x86
cd /tmp/tsos
cd gcc-x86
mkdir -pv build
cd build
../configure --prefix=$TSOS_TOOLCHAIN \
    --enable-languages=c,c++ \
    --disable-libssp \
    --disable-nls \
    --target=i686-elf \
    --disable-libssp \
    --disable-werror \
    --without-headers

make -j$(nproc)
make install
rm -rf /tmp/tsos/gcc-x86

#We will compile binutils for arm
cd /tmp/tsos
cd binutils-arm
mkdir -pv build
cd build
../configure --prefix=$TSOS_TOOLCHAIN \
    --enable-gold \
    --enable-interwork \
    --target=arm-none-eabi \
    --enable-multilib \
    --disable-nls \
    --disable-werror

make -j$(nproc)
make install
rm -rf /tmp/tsos/binutils-arm

#Now we will compile gcc for arm
cd /tmp/tsos
cd gcc-arm
mkdir -pv build
cd build
../configure --prefix=$TSOS_TOOLCHAIN \
    --enable-languages=c,c++ \
    --disable-libssp \
    --disable-nls \
    --target=arm-none-eabi \
    --disable-libssp \
    --disable-werror \
    --without-headers

make -j$(nproc)
make install
rm -rf /tmp/tsos/gcc-arm

#Im sorry that stuff doesnt work rn
exit

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

echo "export PATH=$PATH" >>~/.profile

cd $CODE_DIR
