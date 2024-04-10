FROM ubuntu:22.04

ENV GCC_VERSION=8.1.0
ENV BINUTILS_VERSION=2.41
ENV CLANG_VERSION=11

ENV TARGET=i686-elf
ENV PREFIX=/usr/local

# Add Kitware repo
ADD kitware-archive.sh /kitware-archive.sh
RUN /kitware-archive.sh

# Update package lists
RUN apt-get update

# Install GCC/Binutils build dependencies
RUN apt-get install -y wget build-essential bison texinfo
# Install project build dependencies
RUN apt-get install -y cmake ninja-build grub-common xorriso
# Install Clang tools
RUN apt-get install -y clang-format-$CLANG_VERSION clang-tidy-$CLANG_VERSION
# Install additional dependencies
RUN apt-get install -y sudo

# Build Binutils
ENV BINUTILS=binutils-$BINUTILS_VERSION
RUN wget -q ftp://ftp.gnu.org/gnu/binutils/$BINUTILS.tar.gz && \
    tar -xzf $BINUTILS.tar.gz && \
    mkdir -p /srv/build_binutils && \
    cd /srv/build_binutils && \
    /$BINUTILS/configure --target=$TARGET --prefix="$PREFIX" \
        --with-sysroot --disable-multilib --disable-nls --disable-werror && \
    make && \
    make install

# Build GCC
ENV GCC=gcc-$GCC_VERSION
RUN wget -q ftp://ftp.gnu.org/gnu/gcc/$GCC/$GCC.tar.gz && \
    tar -xzf $GCC.tar.gz && \
    cd /$GCC && \
    contrib/download_prerequisites && \
    mkdir -p /srv/build_gcc && \
    cd /srv/build_gcc && \
    /$GCC/configure --target=$TARGET --prefix="$PREFIX" \
        --disable-multilib --disable-nls --enable-languages=c && \
    make all-gcc && \
    make install-gcc

# Cleanup
RUN rm $GCC.tar.gz $BINUTILS.tar.gz kitware-archive.sh
RUN rm -r /$GCC /$BINUTILS /srv/build_gcc /srv/build_binutils
RUN apt-get clean autoclean

WORKDIR /
