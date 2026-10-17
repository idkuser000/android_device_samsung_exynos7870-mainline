#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

ifeq ($(USES_DEVICE_SAMSUNG_EXYNOS7870_MAINLINE),true)

BOOTMGR_SHARED_LIBS_64_DIR := prebuilts/bootmgr/lib64
BOOTMGR_TOOLS_64_EXEC_ENV := LD_LIBRARY_PATH=$(BOOTMGR_SHARED_LIBS_64_DIR) $(BOOTMGR_SHARED_LIBS_64_DIR)/ld-linux-x86-64.so.2
BOOTMGR_TOOLS_BIN_DIR := prebuilts/bootmgr/tools/$(HOST_PREBUILT_TAG)/bin
BOOTMGR_PATH_OVERRIDE := PATH=$(BOOTMGR_TOOLS_BIN_DIR):$$PATH

GRUB_ARCH := arm64-efi
GRUB_EFI_BOOT_FILENAME := BOOTAA64.EFI
GRUB_CONFIGS := $(COMMON_PATH)/misc/grub.cfg
GRUB_STANDALONE_CONFIGS := $(COMMON_PATH)/misc/grub-standalone.cfg
GRUB_PREBUILT_DIR := prebuilts/bootmgr/grub/$(HOST_PREBUILT_TAG)/$(GRUB_ARCH)

ESP_OUT_DIR := $(TARGET_OUT_INTERMEDIATES)/ESP

INSTALLED_EXYNOS7870_ESPIMAGE_TARGET_INCLUDE_FILES := \
    $(PRODUCT_OUT)/boot.img \
    $(PRODUCT_OUT)/recovery.img

INSTALLED_EXYNOS7870_ESPIMAGE_TARGET_DEPS := \
    $(GRUB_STANDALONE_CONFIGS) \
    $(GRUB_CONFIGS) \
    $(INSTALLED_EXYNOS7870_ESPIMAGE_TARGET_INCLUDE_FILES) \
    $(INSTALLED_KERNEL_TARGET)

# $(1): output file
# $(2): list of contents to include
# $(3): volume label
# $(4): image size in MB (optional)
define create-fat32image
	[ $(4) ] && [ $(4) -gt 0 ] && img_size=$(4) || \
		img_size=$$(python3 $(COMMON_PATH)/build/tools/calc_fat32_img_size.py --label $(3) $(2)); \
		/bin/dd if=/dev/zero of=$(1) bs=1M count=$$img_size
	/sbin/mkfs.fat -n "$(3)" -F 32 -S 4096 $(1)
	$(foreach content,$(2),$(BOOTMGR_TOOLS_BIN_DIR)/mcopy -i $(1) -s $(content) :: &&)true
endef

define make-espimage-target
	$(hide) mkdir -p $(dir $(INSTALLED_EXYNOS7870_ESPIMAGE_TARGET))
	$(call pretty,"Target EFI System Partition image: $(INSTALLED_EXYNOS7870_ESPIMAGE_TARGET)")

	mkdir -p $(ESP_OUT_DIR)/EFI/BOOT $(ESP_OUT_DIR)/boot/grub/fonts

	cp -r $(GRUB_PREBUILT_DIR)/lib/grub/$(GRUB_ARCH) $(ESP_OUT_DIR)/boot/grub/
	cp $(GRUB_PREBUILT_DIR)/share/grub/unicode.pf2 $(ESP_OUT_DIR)/boot/grub/fonts/unicode.pf2

	$(BOOTMGR_PATH_OVERRIDE) $(BOOTMGR_TOOLS_64_EXEC_ENV) $(GRUB_PREBUILT_DIR)/bin/grub-mkstandalone \
		-d $(GRUB_PREBUILT_DIR)/lib/grub/$(GRUB_ARCH) \
		--locales="" \
		--fonts="" \
		--format=$(GRUB_ARCH) \
		--output=$(ESP_OUT_DIR)/EFI/BOOT/$(GRUB_EFI_BOOT_FILENAME) \
		--modules="configfile disk fat part_gpt search" \
		"boot/grub/grub.cfg=$(GRUB_STANDALONE_CONFIGS)"

	touch $(ESP_OUT_DIR)/boot/grub/.is_esp_part_on_android_boot_device

	cat $(GRUB_CONFIGS) > $(ESP_OUT_DIR)/boot/grub/grub.cfg

	mkdir -p $(ESP_OUT_DIR)/dtb/exynos
	cp $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/arch/arm64/boot/dts/exynos/exynos7870-*.dtb $(ESP_OUT_DIR)/dtb/exynos/

	$(call create-fat32image,$(INSTALLED_EXYNOS7870_ESPIMAGE_TARGET),$(ESP_OUT_DIR)/* $(INSTALLED_EXYNOS7870_ESPIMAGE_TARGET_INCLUDE_FILES),EFI)
endef

$(INSTALLED_EXYNOS7870_ESPIMAGE_TARGET): $(INSTALLED_EXYNOS7870_ESPIMAGE_TARGET_DEPS)
	$(call make-espimage-target)

.PHONY: espimage
espimage: $(INSTALLED_EXYNOS7870_ESPIMAGE_TARGET)

.PHONY: espimage-nodeps
espimage-nodeps:
	@echo "make $(INSTALLED_EXYNOS7870_ESPIMAGE_TARGET): ignoring dependencies"
	$(call make-espimage-target)

endif
