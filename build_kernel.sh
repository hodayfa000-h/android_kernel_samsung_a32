#!/bin/bash
set -e

export KERNEL_ROOT=$(realpath "$(dirname "$0")")
export OUT_DIR="$KERNEL_ROOT/out"

echo "🔧 Kernel root: $KERNEL_ROOT"
echo "📦 Output dir: $OUT_DIR"

# Toolchain setup
export CROSS_COMPILE=$KERNEL_ROOT/external_toolchains/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export CC=$KERNEL_ROOT/external_toolchains/clang/host/linux-x86/clang-r407598/bin/clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export ARCH=arm64
export ANDROID_MAJOR_VERSION=r

# Host flags for sortextable
export HOSTCFLAGS="-I$KERNEL_ROOT/tools/include"
export HOSTCXXFLAGS="-I$KERNEL_ROOT/tools/include"

# Optional flags
export KCFLAGS=-w
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y

# Build
make -C "$KERNEL_ROOT" O="$OUT_DIR" a32_defconfig
make -C "$KERNEL_ROOT" O="$OUT_DIR" -j$(nproc --all)

# Copy final image
cp "$OUT_DIR/arch/arm64/boot/Image" "$KERNEL_ROOT/arch/arm64/boot/Image"