#!/usr/bin/env bash
# git clone llvm-project from llvm and git push to my github.
git config --global user.email ramadhananggayudhanto@gmail.com
git config --global user.name ramadhannangga
git clone https://ramadhannangga:$GH_TOKEN@github.com/ramadhannangga/llvm-project
cd llvm-project
git fetch https://github.com/llvm/llvm-project
git merge FETCH_HEAD
git push --force origin main
