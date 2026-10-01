#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/samsung/exynos7870-mainline
TARGET_DEVICE_PATH := device/samsung/exynos7870-mainline/on7xelte_mainline

# Inherit from parent
include device/samsung/exynos7870-mainline/BoardConfig.mk

# Kernel
TARGET_DTB_LIST_WILDCARD := \
    exynos/exynos7870-on7xelte
