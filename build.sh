#!/usr/bin/env bash
# Use iRISxe build script as LLVM Build Script.
git clone https://github.com/ramadhannangga/tc_build $(pwd)/tc_build
cd $(pwd)/tc_build
bash build-tc.sh