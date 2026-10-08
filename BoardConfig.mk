#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

USES_DEVICE_SAMSUNG_EXYNOS7870_MAINLINE := true

# Inherit from mainline/common
include device/mainline/common/BoardConfigMainlineCommon.mk

# A/B
AB_OTA_UPDATER := false

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := cortex-a53
TARGET_CPU_VARIANT_RUNTIME := cortex-a53

# Boot parameters
BOARD_KERNEL_CMDLINE += \
    $(MAINLINE_COMMON_ANDROIDBOOT_PARAMS) \
    $(MAINLINE_COMMON_KERNEL_PARAMS) \
    androidboot.hardware=exynos7870 \
    androidboot.verifiedbootstate=orange \
    console=tty0

# Filesystem
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := true
TARGET_USERIMAGES_USE_F2FS := true
TARGET_USERIMAGES_USE_EXT4 := true

# Kernel
TARGET_KERNEL_SOURCE := kernel/mainline/android-mainline

TARGET_KERNEL_CONFIG := \
    gki_defconfig \
    exynos7870.config

TARGET_DTB_LIST_WILDCARD := \
    exynos/exynos7870-on7xelte

TARGET_KERNEL_CONFIG_EXT := \
    kernel/mainline/configs/fragments/y/fbcon.config \
    kernel/mainline/configs/fragments/n/disable-clang-hardening-features.config \
    kernel/mainline/configs/fragments/n/faster-build-time.config

BOARD_KERNEL_IMAGE_NAME := Image

# OTA
TARGET_SKIP_OTA_PACKAGE := true

# Partitions
BOARD_USES_METADATA_PARTITION := true
BOARD_KERNEL_PAGESIZE := 2048
BOARD_BOOTIMAGE_PARTITION_SIZE := 33554432
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 39845888
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 2871279104
BOARD_USERDATAIMAGE_PARTITION_SIZE := 54618209280
BOARD_VENDORIMAGE_PARTITION_SIZE := 434596224
BOARD_FLASH_BLOCK_SIZE := 4096

# Platform
TARGET_BOARD_PLATFORM := exynos7870-mainline

# Ramdisk
BOARD_RAMDISK_USE_LZMA := true
LZMA_COMPRESSION := -9

# Recovery
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/configs/fstab.exynos7870

# VINTF
DEVICE_MANIFEST_FILE := \
    $(DEVICE_PATH)/configs/manifest.xml
