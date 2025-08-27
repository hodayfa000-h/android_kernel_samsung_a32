#!/bin/bash
set -e

# Define kernel root to avoid path confusion
export KERNEL_ROOT=$(realpath "$(dirname "$0")/..")

# Log current working directory for CI debugging
echo " Current working directory: $(pwd)"
echo " KERNEL_ROOT resolved to: $KERNEL_ROOT"

# Log contents of root repo
echo " Contents of ROOT REPO:"
ls -l "$KERNEL_ROOT"

# Log contents of tools/
echo " Contents of tools/:"
ls -l "$KERNEL_ROOT/tools"

# Log contents of tools/build/
echo " Contents of tools/build/:"
ls -l "$KERNEL_ROOT/tools/build"

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

# Sanity check for cpio binary
if [ ! -f "$KERNEL_ROOT/tools/build/cpio" ]; then
    echo "🫠 Error: cpio binary not found at expected location."
    exit 1
fi

# Ensure cpio binary is executable and visible
chmod +x "$KERNEL_ROOT/tools/build/cpio"
export PATH="$KERNEL_ROOT/tools/build:$PATH"

# Build kernel
echo " Starting kernel build..."
make -C "$KERNEL_ROOT" O="$KERNEL_ROOT/out" KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y -j$(nproc --all) a32_defconfig
make -C "$KERNEL_ROOT" O="$KERNEL_ROOT/out" KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y -j$(nproc --all)

# Copy final Image
echo " Copying final Image..."
cp "$KERNEL_ROOT/out/arch/arm64/boot/Image" "$KERNEL_ROOT/arch/arm64/boot/Image"

echo "✅ Kernel build completed successfully."