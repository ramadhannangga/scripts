#!/usr/bin/env bash
# git clone llvm-project from llvm and git push to my github.
git config --global user.email ramadhananggayudhanto@gmail.com
git config --global user.name ramadhannangga
git clone https://github.com/llvm/llvm-project llvm-project
cd llvm-project
git fetch https://github.com/NusantaraDevs/llvm-project
git cherry-pick 33402aeb52e59392d8f6cb23b0bbe4dc64962860 --signoff
git remote set-url origin https://ramadhannangga:$GH_TOKEN@github.com/ramadhannangga/llvm-project
git push --force origin main