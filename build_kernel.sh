#!/bin/bash
set -e

# Define kernel root to avoid path confusion
export KERNEL_ROOT=$(realpath "$(dirname "$0")")

echo "========== ENVIRONMENT =========="
echo "Current working directory: $(pwd)"
echo "Script location: $0"
echo "Resolved KERNEL_ROOT: $KERNEL_ROOT"
echo "================================="

echo ""
echo "========== ROOT REPO CONTENTS =========="
ls -l "$KERNEL_ROOT"
echo "========================================"

echo ""
echo "========== tools/ CONTENTS =========="
if [ -d "$KERNEL_ROOT/tools" ]; then
    ls -l "$KERNEL_ROOT/tools"
else
    echo "tools/ directory not found at $KERNEL_ROOT/tools"
fi
echo "====================================="

echo ""
echo "========== tools/build/ CONTENTS =========="
if [ -d "$KERNEL_ROOT/tools/build" ]; then
    ls -l "$KERNEL_ROOT/tools/build"
else
    echo "tools/build/ directory not found at $KERNEL_ROOT/tools/build"
fi
echo "==========================================="

echo ""
echo "========== cpio BINARY CHECK =========="
if [ -f "$KERNEL_ROOT/tools/build/cpio" ]; then
    echo "cpio binary found!"
    file "$KERNEL_ROOT/tools/build/cpio"
    ls -l "$KERNEL_ROOT/tools/build/cpio"
else
    echo "❌ Error: cpio binary not found at $KERNEL_ROOT/tools/build/cpio"
    echo "Exiting due to missing binary."
    exit 1
fi
echo "======================================="

# Ensure cpio binary is executable and visible
chmod +x "$KERNEL_ROOT/tools/build/cpio"
export PATH="$KERNEL_ROOT/tools/build:$PATH"

echo ""
echo "========== TOOLCHAIN SETUP =========="
echo "CROSS_COMPILE: $CROSS_COMPILE"
echo "CC: $CC"
echo "CLANG_TRIPLE: $CLANG_TRIPLE"
echo "ARCH: $ARCH"
echo "ANDROID_MAJOR_VERSION: $ANDROID_MAJOR_VERSION"
echo "====================================="

# Toolchain paths
export CROSS_COMPILE=$KERNEL_ROOT/tools/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export CC=$KERNEL_ROOT/tools/clang/host/linux-x86/clang-r407598/bin/clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export ARCH=arm64
export ANDROID_MAJOR_VERSION=r

# Inject header path for sortextable
export HOSTCFLAGS="-I$KERNEL_ROOT/tools/include"
export HOSTCXXFLAGS="-I$KERNEL_ROOT/tools/include"

# Optional flags
export KCFLAGS=-w
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y

echo ""
echo "========== BUILDING KERNEL =========="
make -C "$KERNEL_ROOT" O="$KERNEL_ROOT/out" KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y -j$(nproc --all) a32_defconfig
make -C "$KERNEL_ROOT" O="$KERNEL_ROOT/out" KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y -j$(nproc --all)
echo "====================================="

echo ""
echo "========== COPYING FINAL IMAGE =========="
cp "$KERNEL_ROOT/out/arch/arm64/boot/Image" "$KERNEL_ROOT/arch/arm64/boot/Image"
ls -lh "$KERNEL_ROOT/arch/arm64/boot/Image"
echo "========================================="