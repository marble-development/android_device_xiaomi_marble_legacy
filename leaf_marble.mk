#
# Copyright (C) 2023 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Leaf stuff.
$(call inherit-product, vendor/leaf/config/common_full_phone.mk)

# Inherit from marble device.
$(call inherit-product, device/xiaomi/marble/device.mk)

# Device identifier
PRODUCT_DEVICE := marble
PRODUCT_NAME := leaf_marble
PRODUCT_MANUFACTURER := Xiaomi

# Google apps
WITH_GMS :=
WITH_MICROG :=
PRODUCT_GMS_CLIENTID_BASE := android-xiaomi
