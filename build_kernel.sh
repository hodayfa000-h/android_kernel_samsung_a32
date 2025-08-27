#!/bin/bash
set -e

# Toolchain paths
export CROSS_COMPILE=$(pwd)/tools/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export CC=$(pwd)/tools/clang/host/linux-x86/clang-r407598/bin/clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export ARCH=arm64
export ANDROID_MAJOR_VERSION=r

# Optional flags
export KCFLAGS=-w
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y

# Build kernel
make -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y -j$(nproc --all) a32_defconfig
make -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y -j$(nproc --all)

# Copy final Image
cp out/arch/arm64/boot/Image $(pwd)/arch/arm64/boot/Image
