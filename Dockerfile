FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
        # GCC, Binutils:
        wget build-essential gcc texinfo \
        # CMake build:
        sudo ninja-build clang-tidy grub-common xorriso mtools

ENV DOWNLOAD_BINUTILS=binutils-2.41
ENV DOWNLOAD_GCC=gcc-8.1.0

ENV TARGET=i686-elf
ENV PREFIX=/usr/local

# Binutils
RUN wget -q http://ftp.gnu.org/gnu/binutils/$DOWNLOAD_BINUTILS.tar.gz && \
    tar -xzf $DOWNLOAD_BINUTILS.tar.gz && \
    mkdir -p /srv/build_binutils && \
    cd /srv/build_binutils && \
    /$DOWNLOAD_BINUTILS/configure \
        --target=$TARGET \
        --prefix="$PREFIX" \
        --with-sysroot --disable-multilib --disable-nls --disable-werror && \
    make && \
    make install && \
    rm -r /$DOWNLOAD_BINUTILS /srv/build_binutils

# GCC
RUN wget -q ftp://ftp.gnu.org/gnu/gcc/$DOWNLOAD_GCC/$DOWNLOAD_GCC.tar.gz && \
    tar -xzf $DOWNLOAD_GCC.tar.gz && \
    cd /$DOWNLOAD_GCC && contrib/download_prerequisites && \
    mkdir -p /srv/build_gcc && \
    cd /srv/build_gcc && \
    /$DOWNLOAD_GCC/configure \
        --target=$TARGET \
        --prefix="$PREFIX" \
        --disable-multilib --disable-nls --enable-languages=c && \
    make all-gcc && \
    make install-gcc && \
    rm -r /$DOWNLOAD_GCC /srv/build_gcc

# Cleanup
RUN apt-get clean autoclean

WORKDIR /
