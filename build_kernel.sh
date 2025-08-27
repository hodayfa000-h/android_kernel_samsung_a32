#!/bin/bash
set -e

# Define outer repo root
export OUTER_REPO_ROOT=$(realpath "$(dirname "$0")/..")

# Define nested kernel root (where this script lives)
export KERNEL_ROOT=$(realpath "$(dirname "$0")")

echo "========== OUTER REPO ROOT =========="
echo "OUTER_REPO_ROOT: $OUTER_REPO_ROOT"
ls -l "$OUTER_REPO_ROOT"

echo ""
echo "========== NESTED KERNEL ROOT =========="
echo "KERNEL_ROOT: $KERNEL_ROOT"
ls -l "$KERNEL_ROOT"

echo ""
echo "========== tools/build in NESTED KERNEL ROOT =========="
ls -l "$KERNEL_ROOT/tools/build" || echo "tools/build not found."

echo ""
echo "========== Direct check: ls -l on nested tools/build =========="
ls -l /home/runner/work/android_kernel_samsung_a32/android_kernel_samsung_a32/tools/build || echo "Direct path tools/build not found."

# Choose correct path for cpio binary
if [ -f "$KERNEL_ROOT/tools/build/cpio" ]; then
    export CPIO_PATH="$KERNEL_ROOT/tools/build/cpio"
else
    echo "Error: cpio binary not found in tools/build"
    exit 1
fi

# Make sure cpio is executable and in PATH
chmod +x "$CPIO_PATH"
export PATH="$(dirname "$CPIO_PATH"):$PATH"

# Toolchain paths (from FalconJaw clone)
export CROSS_COMPILE=$KERNEL_ROOT/external_toolchains/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export CC=$KERNEL_ROOT/external_toolchains/clang/host/linux-x86/clang-r407598/bin/clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export ARCH=arm64
export ANDROID_MAJOR_VERSION=r

# Inject header path for sortextable
export HOSTCFLAGS="-I$KERNEL_ROOT/tools/include"
export HOSTCXXFLAGS="-I$KERNEL_ROOT/tools/include"

# Optional flags
export KCFLAGS=-w
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y

# Build kernel
make -C "$KERNEL_ROOT" O="$KERNEL_ROOT/out" KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y -j$(nproc --all) a32_defconfig
make -C "$KERNEL_ROOT" O="$KERNEL_ROOT/out" KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y -j$(nproc --all)

# Copy final Image
cp "$KERNEL_ROOT/out/arch/arm64/boot/Image" "$KERNEL_ROOT/arch/arm64/boot/Image"