#!/usr/bin/env bash
#
# Copyright (C) 2021 a xyzprjkt property
#

# Needed Secret Variable
# KERNEL_NAME | Your kernel name
# KERNEL_SOURCE | Your kernel link source
# KERNEL_BRANCH  | Your needed kernel branch if needed with -b. eg -b eleven_eas
# DEVICE_CODENAME | Your device codename
# DEVICE_DEFCONFIG | Your device defconfig eg. lavender_defconfig
# ANYKERNEL | Your Anykernel link repository
# TG_TOKEN | Your telegram bot token
# TG_CHAT_ID | Your telegram private ci chat id
# BUILD_USER | Your username
# BUILD_HOST | Your hostname

echo "Downloading few Dependecies . . ."
# Kernel Sources
git clone --depth=1 $KERNEL_SOURCE -b $KERNEL_BRANCH $DEVICE_CODENAME
git clone --depth=1 https://gitlab.com/ramadhannangga/irisxe-clang iRISxe # iRISxe set as Clang Default
git clone --depth=1 https://github.com/theradcolor/aarch64-linux-gnu -b stable-gcc gcc64
git clone --depth=1 https://github.com/theradcolor/arm-linux-gnueabi -b stable-gcc gcc

# Main Declaration
KERNEL_ROOTDIR=$(pwd)/$DEVICE_CODENAME # IMPORTANT ! Fill with your kernel source root directory.
DEVICE_DEFCONFIG=$DEVICE_DEFCONFIG # IMPORTANT ! Declare your kernel source defconfig file here.
CLANG_ROOTDIR=$(pwd)/iRISxe # IMPORTANT! Put your clang directory here.
GCC64_ROOTDIR=$(pwd)/gcc64 # IMPORTANT! Put your gcc64 directory here.
GCC_ROOTDIR=$(pwd)/gcc # IMPORTANT! Put your gcc directory here.
export KBUILD_BUILD_USER=$BUILD_USER # Change with your own name or else.
export KBUILD_BUILD_HOST=$BUILD_HOST # Change with your own hostname.

# Main Declaration
CLANG_VER="$("$CLANG_ROOTDIR"/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')"
LLD_VER="$("$CLANG_ROOTDIR"/bin/ld.lld --version | head -n 1)"
GCC64_VER="$("$GCC64_ROOTDIR"/bin/aarch64-linux-gnu-gcc --version | head -n 1)"
GCC_VER="$("$GCC_ROOTDIR"/bin/arm-linux-gnueabi-gcc --version | head -n 1)"
export KBUILD_COMPILER_STRING="$CLANG_VER with $GCC64_VER and $GCC_VER"
IMAGE=$(pwd)/$DEVICE_CODENAME/out/arch/arm64/boot/Image.gz-dtb
CODENAME="ASUS_X01BDA"
DATE=$(date +"%F-%S")
COMMIT=$(git log --pretty=format:'%h' -1)
KVER=(""4.4.$(cat "$(pwd)/$DEVICE_CODENAME/Makefile" | grep "SUBLEVEL =" | sed 's/SUBLEVEL = *//g')$(cat "$(pwd)/$DEVICE_CODENAME/Makefile" | grep "EXTRAVERSION =" | sed 's/EXTRAVERSION = *//g')"")
MODEL="ASUS ZenFone Max Pro M2"
MANUFACTURERINFO="ASUSTek Computer Inc."
START=$(date +"%s")
VARIANT="XR"

# Checking environtment
# Warning !! Dont Change anything there without known reason.
function check() {
echo ================================================
echo KernelCompiler
echo version : rev1.5 - gaspoll
echo ================================================
echo BUILDER NAME = ${KBUILD_BUILD_USER}
echo BUILDER HOSTNAME = ${KBUILD_BUILD_HOST}
echo DEVICE_DEFCONFIG = ${DEVICE_DEFCONFIG}
echo TOOLCHAIN_VERSION = ${KBUILD_COMPILER_STRING}
echo CLANG_ROOTDIR = ${CLANG_ROOTDIR}
echo GCC64_ROOTDIR = ${GCC64_ROOTDIR}
echo GCC_ROOTDIR = ${GCC_ROOTDIR}
echo KERNEL_ROOTDIR = ${KERNEL_ROOTDIR}
echo ================================================
}

# Telegram
export BOT_MSG_URL="https://api.telegram.org/bot$TG_TOKEN/sendMessage"

tg_post_msg() {
  curl -s -X POST "$BOT_MSG_URL" -d chat_id="$TG_CHAT_ID" \
  -d "disable_web_page_preview=true" \
  -d "parse_mode=html" \
  -d text="$1"

}

# Post Main Information
tg_post_msg "<b>KernelCompiler</b>%0ADevices : <code>${CODENAME}</code>%0AModel : <code>${MODEL}</code>%0AManufacturer : <code>${MANUFACTURERINFO}</code>%0AKernel Version : <code>${KVER}</code>%0ADevice Defconfig: <code>${DEVICE_DEFCONFIG}</code>%0ACommit : <code>${COMMIT}</code>%0ABuilder Name : <code>${KBUILD_BUILD_USER}</code>%0ABuilder Host : <code>${KBUILD_BUILD_HOST}</code>%0AClang Version : <code>${KBUILD_COMPILER_STRING}</code>%0AClang Rootdir : <code>${CLANG_ROOTDIR}</code>%0AKernel Rootdir : <code>${KERNEL_ROOTDIR}</code>"

# Compile
compile(){
tg_post_msg "<b>Compilation has started</b>%0ASTART <code>${START}</code>"
cd ${KERNEL_ROOTDIR}
make -j$(nproc) O=out ${DEVICE_DEFCONFIG}
make -j$(nproc) O=out \
    ARCH=arm64 \
    SUBARCH=arm64 \
    PATH=${CLANG_ROOTDIR}/bin:${PATH} \
    CC=${CLANG_ROOTDIR}/bin/clang \
    CROSS_COMPILE=${GCC64_ROOTDIR}/bin/aarch64-linux-gnu- \
    CROSS_COMPILE_ARM32=${GCC_ROOTDIR}/bin/arm-linux-gnueabi- \
    AR=${CLANG_ROOTDIR}/bin/llvm-ar \
    NM=${CLANG_ROOTDIR}/bin/llvm-nm \
    OBJCOPY=${CLANG_ROOTDIR}/bin/llvm-objcopy \
    OBJDUMP=${CLANG_ROOTDIR}/bin/llvm-objdump \
    STRIP=${CLANG_ROOTDIR}/bin/llvm-strip \
    CLANG_TRIPLE=aarch64-linux-gnu-

   if ! [ -a "$IMAGE" ]; then
	finerr
	exit 1
   fi

  git clone --depth=1 $ANYKERNEL AnyKernel
	cp $IMAGE AnyKernel
}

# Push kernel to channel
function push() {
    cd AnyKernel
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP "https://api.telegram.org/bot$TG_TOKEN/sendDocument" \
        -F chat_id="$TG_CHAT_ID" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Compile took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). | <b>${KBUILD_COMPILER_STRING}</b>"
}
# Fin Error
function finerr() {
    curl -s -X POST "https://api.telegram.org/bot$TG_TOKEN/sendMessage" \
        -d chat_id="$TG_CHAT_ID" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="Build throw an error(s)"
    exit 1
}

# Zipping
function zipping() {
    cd AnyKernel || exit 1
    zip -r9 [$VARIANT]$KVER-$KERNEL_NAME.zip *
    cd ..
}
check
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
push
