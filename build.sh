#!/usr/bin/env bash
# install packages

apt-get update -qq && \
apt-get upgrade -y && \
apt-get install --no-install-recommends -y \
            binutils-dev \
            bison \
            ca-certificates \
            ccache \
            clang \
            cmake \
            curl \
            file \
            flex \
            gcc \
            g++ \
            git \
            libelf-dev \
            libssl-dev \
            make \
            ninja-build \
            python3 \
            texinfo \
            u-boot-tools \
            xz-utils \
            zlib1g-dev
   
# git clone   
            
git clone https://github.com/ramadhannangga/tc_build $(pwd)/tc_build
cd $(pwd)/tc_build
bash build-tc.sh
