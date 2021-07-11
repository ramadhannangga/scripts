#!/usr/bin/env bash
git clone https://github.com/ramadhannangga/build --depth=1 build
git clone https://github.com/ramadhannangga/llvm-project -b release/12.x --depth=1 llvm-project
git clone https://github.com/bminor/binutils-gdb -b binutils-2_37-branch --depth=1 llvm-project/llvm/tools/binutils
./llvm.sh 13
cd build || exit 1
export CC=/usr/bin/clang
export CXX=/usr/bin/clang++
bash build_dtc 12.0
export TOOLCHAIN_ROOT="$(dirname "$(pwd)")"
export DTC_VERSION=12.0
export PREFIX_PATH=$TOOLCHAIN_ROOT/out/$DTC_VERSION
git config --global user.name ramadhannangga
git config --global user.email ramadhananggayudhanto@gmail.com
git config --global http.version HTTP/1.1
git config http.postBuffer 524288000
cd $PREFIX_PATH
if ! [ -a lib64/libomp.so.5 ]; then
    echo "linking libomp.so"
    cd lib64
    ln -s libomp.so libomp.so.5
    cd ..
fi
chmod -R 777 $PREFIX_PATH
git init
git checkout -b 12.0
git add .
git commit -m "$DTC_VERSION-iRISxeTC-$(date +'%d%m%y')" --signoff
git remote add origin https://ramadhannangga:$GH_TOKEN@github.com/ramadhannangga/iRISxe-Clang.gi
git push --force origin 12.0
