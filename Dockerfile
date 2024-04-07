FROM ubuntu:22.04

ENV BINUTILS_VERSION=2.41
ENV GCC_VERSION=8.1.0

ENV PLATFORM=i686-elf
ENV PREFIX=/usr/local

# Add Kitware repo for CMake
ADD kitware-archive.sh /kitware-archive.sh
RUN /kitware-archive.sh

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
        wget build-essential gcc texinfo \
        sudo cmake ninja-build grub-common xorriso mtools

# Build Binutils
RUN wget -q http://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.gz && \
    tar -xzf binutils-$BINUTILS_VERSION.tar.gz && \
    mkdir -p /srv/build_binutils && \
    cd /srv/build_binutils && \
    /binutils-$BINUTILS_VERSION/configure \
        --target=$TARGET \
        --prefix="$PREFIX" \
        --with-sysroot --disable-multilib --disable-nls --disable-werror && \
    make && \
    make install && \
    rm -r /binutils-$BINUTILS_VERSION /srv/build_binutils

# Build GCC
RUN wget -q ftp://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz && \
    tar -xzf gcc-$GCC_VERSION.tar.gz && \
    cd /gcc-$GCC_VERSION && contrib/download_prerequisites && \
    mkdir -p /srv/build_gcc && \
    cd /srv/build_gcc && \
    /gcc-$GCC_VERSION/configure \
        --target=$TARGET \
        --prefix="$PREFIX" \
        --disable-multilib --disable-nls --enable-languages=c && \
    make all-gcc && \
    make install-gcc && \
    rm -r /gcc-$GCC_VERSION /srv/build_gcc

RUN apt-get clean autoclean

WORKDIR /
