#!/bin/bash

set -e

UNILOADER_PATH=external/uniLoader

export ARCH=aarch64
export CROSS_COMPILE=aarch64-linux-gnu-

rm -rf $UNILOADER_PATH
git clone https://github.com/idkuser000/uniLoader $UNILOADER_PATH

cp $OUT/kernel $UNILOADER_PATH/blob/Image
cp $OUT/ramdisk-recovery.img $UNILOADER_PATH/blob/ramdisk
cp $OUT/obj/DTB_OBJ/arch/arm64/boot/dts/exynos/exynos7870-on7xelte.dtb $UNILOADER_PATH/blob/dtb

echo "Building uniLoader for on7xelte..."
cd "$UNILOADER_PATH"

make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE on7xelte_defconfig
make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE

# Making boot.img from uniLoader binary
mv $OUT/recovery.img $OUT/recovery.img.orig
mkbootimg -o $OUT/recovery-uniloader.img --kernel $UNILOADER_PATH/uniLoader --cmdline "androidboot.init_fatal_reboot_target=recovery androidboot.boot_devices=any androidboot.selinux=permissive binder.impl=rust firmware_class.path=/vendor/firmware/ log_buf_len=4M loop.max_part=7 printk.devkmsg=on rw vt.global_cursor_default=0 audit=0 panic=-1 androidboot.hardware=exynos7870 androidboot.verifiedbootstate=orange console=tty0"

echo "uniLoader with recovery ramdisk built!"
