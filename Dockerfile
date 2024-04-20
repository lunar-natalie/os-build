FROM ubuntu:22.04

ENV GCC_VERSION=8.1.0
ENV BINUTILS_VERSION=2.41
ENV TARGET=i686-elf
ENV PREFIX=/usr/local

# Install GCC/Binutils build dependencies
RUN apt-get update && \
    apt-get install -y wget build-essential bison texinfo

# Build Binutils
ENV BINUTILS=binutils-$BINUTILS_VERSION
RUN wget -q ftp://ftp.gnu.org/gnu/binutils/$BINUTILS.tar.gz && \
    tar -xzf $BINUTILS.tar.gz && \
    mkdir -p /srv/build_binutils && \
    cd /srv/build_binutils && \
    /$BINUTILS/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-multilib --disable-nls --disable-werror && \
    make && \
    make install && \
    rm /$BINUTILS.tar.gz && \
    rm -r /$BINUTILS /srv/build_binutils

# Build GCC
ENV GCC=gcc-$GCC_VERSION
RUN wget -q ftp://ftp.gnu.org/gnu/gcc/$GCC/$GCC.tar.gz && \
    tar -xzf $GCC.tar.gz && \
    cd /$GCC && \
    ./contrib/download_prerequisites && \
    mkdir -p /srv/build_gcc && \
    cd /srv/build_gcc && \
    /$GCC/configure --target=$TARGET --prefix="$PREFIX" --disable-multilib --disable-nls --enable-languages=c && \
    make all-gcc && \
    make install-gcc && \
    rm /$GCC.tar.gz && \
    rm -r /$GCC /srv/build_gcc

# Add Kitware repo and install CMake
ADD kitware-archive.sh /kitware-archive.sh
RUN chmod +x /kitware-archive.sh && \
    /kitware-archive.sh && \
    rm /kitware-archive.sh
RUN apt-get update && \
    apt-get install -y cmake

ENV CLANG_VERSION=11
ENV PYTHON_VERSION=3.10

# Install project build dependencies
RUN apt-get install -y ninja-build grub-common xorriso
# Install Clang tools
RUN apt-get install -y clang-format-$CLANG_VERSION clang-tidy-$CLANG_VERSION
# Install cpp-linter dependencies
RUN apt-get install -y python${PYTHON_VERSION} python${PYTHON_VERSION}-dev sudo lsb-release software-properties-common gnupg

# Cleanup
RUN apt-get clean autoclean

WORKDIR /
