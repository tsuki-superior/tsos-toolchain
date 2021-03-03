#!/usr/bin/env bash
# By Tsuki Superior

# TS/OS toolchain location
TSOS_TOOLCHAIN=/usr/tsos-toolchain/

# Remove previous installation
rm -rfv $TSOS_TOOLCHAIN

# Add new installation
mkdir -pv $TSOS_TOOLCHAIN/tools

# The version of gcc that will be used here
GCC_VERSION=10.1.0

# The version of binutils that will be used here
BINUTILS_VERSION=2.35

# The version of gba tools i will use
GBA_TOOLS_VERSION=1.2.0

# The url for gcc`s tarball
GCC_DOWNLOAD_URL=https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.xz

# The url for binutils`s tarball
BINUTILS_DOWNLOAD_URL=https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.xz

# The url for gba-tools
GBA_TOOLS_DOWNLOAD_URL=https://github.com/devkitPro/gba-tools/releases/download/v$GBA_TOOLS_VERSION/gba-tools-$GBA_TOOLS_VERSION.tar.bz2

# Prepare and move to the directory
rm -rfv /tmp/tsos
mkdir -pv /tmp/tsos
cd /tmp/tsos || exit 1

# Get the tools from the web
wget $GCC_DOWNLOAD_URL
wget $BINUTILS_DOWNLOAD_URL
wget $GBA_TOOLS_DOWNLOAD_URL

# Extracting and copying gcc tarballs
tar -xf gcc-$GCC_VERSION.tar.xz
mv -v gcc-$GCC_VERSION/ gcc-x86/
cp -R gcc-x86/ gcc-arm/
cp -R gcc-x86/ gcc-mipsel/

# Extracting and copying binutils tarballs
tar -xf binutils-$BINUTILS_VERSION.tar.xz
mv -v binutils-$BINUTILS_VERSION/ binutils-x86/
cp -R binutils-x86/ binutils-arm/
cp -R binutils-x86/ binutils-mipsel/

# Extracting gba tools tarballs
tar -xf gba-tools-$GBA_TOOLS_VERSION.tar.bz2
mv -v gba-tools-$GBA_TOOLS_VERSION/ gba-tools/

# Lets update that path variable
export PATH=$PATH:$TSOS_TOOLCHAIN/bin
echo "export PATH=$PATH" >>~/.bashrc
echo "export PATH=$PATH" >>~/.profile

# GBA tools will be first
cd gba-tools || exit 1
mkdir -pv build
cd build || exit 1
../configure  --prefix=$TSOS_TOOLCHAIN \
    --program-prefix=tsos-

make -j"$(nproc)"
make install
cd /tmp/tsos || exit 1
rm -rf /tmp/tsos/gba-tools

# We will compile binutils first for x86
cd binutils-x86 || exit 1
mkdir -pv build
cd build || exit 1
../configure --prefix=$TSOS_TOOLCHAIN \
    --enable-gold \
    --enable-interwork \
    --target=i686-elf \
    --enable-multilib \
    --disable-nls \
    --disable-werror \
    --program-prefix=tsos-i686-

make -j"$(nproc)"
make install
cd /tmp/tsos || exit 1
rm -rf /tmp/tsos/binutils-x86

# Now we will compile gcc for x86
cd gcc-x86 || exit 1
./contrib/download_prerequisites
mkdir -pv build
cd build || exit 1
../configure --prefix=$TSOS_TOOLCHAIN \
    --enable-languages=c,c++ \
    --disable-libssp \
    --disable-nls \
    --target=i686-elf \
    --disable-libssp \
    --disable-werror \
    --without-headers \
    --disable-libada \
    --disable-libssp \
    --disable-bootstrap \
    --program-prefix=tsos-i686-

make -j"$(nproc)"
make install
cd /tmp/tsos || exit 1
rm -rf /tmp/tsos/gcc-x86

# We will compile binutils for arm
cd binutils-arm || exit 1
mkdir -pv build
cd build || exit 1
../configure --prefix=$TSOS_TOOLCHAIN \
    --enable-gold \
    --enable-interwork \
    --target=arm-none-eabi \
    --enable-multilib \
    --disable-nls \
    --disable-werror \
    --disable-threads \
    --disable-libada \
    --disable-libssp \
    --program-prefix=tsos-armeabi-

make -j"$(nproc)"
make install
cd /tmp/tsos || exit 1
rm -rf /tmp/tsos/binutils-arm

# Compiling gcc for arm
cd gcc-arm || exit 1
./contrib/download_prerequisites
mkdir -pv build
cd build || exit 1
../configure --prefix=$TSOS_TOOLCHAIN \
    --enable-languages=c,c++ \
    --disable-libssp \
    --disable-nls \
    --target=arm-none-eabi \
    --disable-libssp \
    --disable-werror \
    --without-headers \
    --disable-libada \
    --disable-libssp \
    --disable-bootstrap \
    --program-prefix=tsos-armeabi-

make -j"$(nproc)"
make install
cd /tmp/tsos || exit 1
rm -rf /tmp/tsos/gcc-arm

# We will compile binutils for mipsel
cd binutils-mipsel || exit 1
mkdir -pv build
cd build || exit 1
../configure --prefix=$TSOS_TOOLCHAIN \
    --enable-gold \
    --enable-interwork \
    --target=mipsel-unknown-elf \
    --enable-multilib \
    --disable-nls \
    --disable-werror \
    --disable-threads \
    --disable-libada \
    --disable-libssp \
    --with-float=soft \
    --program-prefix=tsos-mipsel-

make -j"$(nproc)"
make install
cd /tmp/tsos || exit 1
rm -rf /tmp/tsos/binutils-mipsel

# Compiling gcc for mipsel
cd gcc-mipsel || exit 1
./contrib/download_prerequisites
mkdir -pv build
cd build || exit 1
../configure --prefix=$TSOS_TOOLCHAIN \
    --enable-languages=c,c++ \
    --disable-libssp \
    --disable-nls \
    --target=mipsel-unknown-elf \
    --disable-libssp \
    --disable-werror \
    --without-headers \
    --disable-libada \
    --disable-libssp \
    --disable-bootstrap \
    --with-float=soft \
    --program-prefix=tsos-mipsel-

make -j"$(nproc)"
make install
cd /tmp/tsos || exit 1
rm -rf /tmp/tsos/gcc-mipsel

exit
