#
# Copyright (C) 2023 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit virtual_ab_ota_product.
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)

# Enable project quotas and casefolding for emulated storage without sdcardfs.
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# Enable updating of APEXes
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

# Setup dalvik vm configs
$(call inherit-product, frameworks/native/build/phone-xhdpi-6144-dalvik-heap.mk)

# AAPT
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := xxhdpi

# A/B
AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_vendor=true \
    POSTINSTALL_PATH_vendor=bin/checkpoint_gc \
    FILESYSTEM_TYPE_vendor=ext4 \
    POSTINSTALL_OPTIONAL_vendor=true

PRODUCT_PACKAGES += \
    checkpoint_gc \
    otapreopt_script

# AIDL NDK backend
PRODUCT_PACKAGES += \
    android.hardware.common-V2-ndk_platform.vendor \
    android.hardware.gnss-V1-ndk_platform.vendor \
    android.hardware.identity-V3-ndk_platform.vendor \
    android.hardware.keymaster-V3-ndk_platform.vendor \
    android.hardware.light-V1-ndk_platform.vendor \
    android.hardware.memtrack-V1-ndk_platform.vendor \
    android.hardware.security.keymint-V1-ndk_platform.vendor \
    android.hardware.security.secureclock-V1-ndk_platform.vendor \
    android.hardware.security.sharedsecret-V1-ndk_platform.vendor \
    vendor.qti.hardware.display.config-V1-ndk_platform.vendor \
    vendor.qti.hardware.display.config-V2-ndk_platform.vendor \
    vendor.qti.hardware.display.config-V3-ndk_platform.vendor \
    vendor.qti.hardware.display.config-V4-ndk_platform.vendor \
    vendor.qti.hardware.display.config-V5-ndk_platform.vendor \
    vendor.qti.hardware.display.config-V6-ndk_platform.vendor

# Boot animation
TARGET_BOOT_ANIMATION_RES := 1080

# Boot control
PRODUCT_PACKAGES += \
    android.hardware.boot@1.2-impl-qti \
    android.hardware.boot@1.2-impl-qti.recovery \
    android.hardware.boot@1.2-service

PRODUCT_PACKAGES_DEBUG += \
    bootctl

# Input
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/idc/uinput-fpc.idc:$(TARGET_COPY_OUT_SYSTEM)/usr/idc/uinput-fpc.idc \
    $(LOCAL_PATH)/configs/idc/uinput-goodix.idc:$(TARGET_COPY_OUT_SYSTEM)/usr/idc/uinput-goodix.idc \
    $(LOCAL_PATH)/configs/keylayout/uinput-fpc.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/uinput-fpc.kl \
    $(LOCAL_PATH)/configs/keylayout/uinput-goodix.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/uinput-goodix.kl

# Overlays
DEVICE_PACKAGE_OVERLAYS += \
    $(LOCAL_PATH)/overlay-lineage

PRODUCT_PACKAGES += \
    AospWifiResOverlayMarble \
    ApertureResOverlay \
    CarrierConfigResMarble \
    FrameworksResCommon \
    FrameworksResOverlayMarble \
    SettingsOverlayMarble \
    SystemUIOverlayMarble \
    TelecommResCommon \
    TelephonyResCommon \
    TetheringResCommon \
    WifiResMarble \
    WifiResTarget

PRODUCT_PACKAGES += \
    AospWifiResOverlayMarbleChina \
    AospWifiResOverlayMarbleGlobal \
    AospWifiResOverlayMarbleIndia \
    SettingsOverlayGlobal \
    SettingsOverlayIndia \
    SettingsOverlayChina \
    SettingsProviderOverlayGlobal \
    SettingsProviderOverlayIndia \
    SettingsProviderOverlayChina

# Partitions
PRODUCT_BUILD_SUPER_PARTITION := false
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# RIL
PRODUCT_PACKAGES += \
    Ims \
    QtiTelephony \
    qti-telephony-common

# Rootdir
PRODUCT_PACKAGES += \
    charger_fw_fstab.qti \
    fstab.qcom \
    init.class_main.sh \
    init.qcom.class_core.sh \
    init.qcom.early_boot.sh \
    init.qcom.post_boot.sh \
    init.qcom.rc \
    init.qcom.sh \
    init.recovery.qcom.rc \
    init.target.rc \
    ueventd.qcom.rc \
    ueventd-odm.rc

# Telephony
PRODUCT_PACKAGES += \
    ims-ext-common \
    ims_ext_common.xml \
    qti-telephony-hidl-wrapper \
    qti_telephony_hidl_wrapper.xml \
    qti-telephony-utils \
    qti_telephony_utils.xml \
    telephony-ext

PRODUCT_BOOT_JARS += \
    telephony-ext
    
# Update engine
PRODUCT_PACKAGES += \
    update_engine \
    update_engine_sideload \
    update_verifier

PRODUCT_PACKAGES_DEBUG += \
    update_engine_client

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(DEVICE_PATH)
