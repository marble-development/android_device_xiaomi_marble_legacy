#
# Copyright (C) 2023 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit virtual_ab_ota_product.
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)

# Installs gsi keys into ramdisk, to boot a developer GSI with verified boot.
$(call inherit-product, $(SRC_TARGET_DIR)/product/developer_gsi_keys.mk)

# Setup dalvik vm configs.
$(call inherit-product, frameworks/native/build/phone-xhdpi-6144-dalvik-heap.mk)

# Call the proprietary setup.
$(call inherit-product, vendor/xiaomi/marble/marble-vendor.mk)

# Enable updating of APEXes.
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

# Project ID Quota.
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

DEVICE_PATH := device/xiaomi/marble

# SHIPPING API
PRODUCT_SHIPPING_API_LEVEL := 31

# VNDK API
PRODUCT_TARGET_VNDK_VERSION := 32
PRODUCT_EXTRA_VNDK_VERSIONS := 32

# A/B
AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=erofs \
    POSTINSTALL_OPTIONAL_system=true

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_vendor=true \
    POSTINSTALL_PATH_vendor=bin/checkpoint_gc \
    FILESYSTEM_TYPE_vendor=erofs \
    POSTINSTALL_OPTIONAL_vendor=true

# Bluetooth Audio (System-side HAL, sysbta)
PRODUCT_PACKAGES += \
    audio.sysbta.default \
    android.hardware.bluetooth.audio-service-system \
    libldacBT_abr \
    libldacBT_bco \
    libldacBT_enc

# Boot animation
TARGET_BOOT_ANIMATION_RES := 1080

# Boot control
PRODUCT_PACKAGES += \
    android.hardware.boot@1.2-impl-qti \
    android.hardware.boot@1.2-impl-qti.recovery \
    android.hardware.boot@1.2-service

PRODUCT_PACKAGES_DEBUG += \
    bootctl

# Displayconfig
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/displayconfig/display_id_4630946480857061762.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/displayconfig/display_id_4630946480857061762.xml \
    $(DEVICE_PATH)/configs/displayconfig/display_id_4630946370515662722.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/displayconfig/display_id_4630946370515662722.xml \
    $(DEVICE_PATH)/configs/displayconfig/resolution_switch_process_list_backup.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/displayconfig/resolution_switch_process_list_backup.xml \
    $(DEVICE_PATH)/configs/displayconfig/thermal_brightness_control.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/thermal_brightness_control.xml

# Dtb
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/prebuilts/dtb:dtb.img

# DT2W
PRODUCT_PACKAGES += \
    DT2W-Service-Marble

# Fastbootd
PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.1-impl-mock \
    fastbootd

# F2FS utilities
PRODUCT_PACKAGES += \
    sg_write_buffer \
    f2fs_io \
    check_f2fs

# Health
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl.recovery

# HotwordEnrollement
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/permissions/hotword-hiddenapi-package-whitelist.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/sysconfig/hotword-hiddenapi-package-whitelist.xml \
    $(DEVICE_PATH)/configs/permissions/privapp-permissions-hotword.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-hotword.xml

# Input
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/idc/uinput-fpc.idc:$(TARGET_COPY_OUT_SYSTEM)/usr/idc/uinput-fpc.idc \
    $(DEVICE_PATH)/configs/idc/uinput-goodix.idc:$(TARGET_COPY_OUT_SYSTEM)/usr/idc/uinput-goodix.idc \
    $(DEVICE_PATH)/configs/idc/uinput-fortsense.idc:$(TARGET_COPY_OUT_SYSTEM)/usr/idc/uinput-fortsense.idc

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/keylayout/uinput-fpc.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/uinput-fpc.kl \
    $(DEVICE_PATH)/configs/keylayout/uinput-goodix.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/uinput-goodix.kl \
    $(DEVICE_PATH)/configs/keylayout/uinput-fortsense.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/uinput-fortsense.kl \
    $(DEVICE_PATH)/configs/keylayout/Vendor_0079_Product_0011.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_0079_Product_0011.kl \
    $(DEVICE_PATH)/configs/keylayout/Vendor_045e_Product_028e.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_045e_Product_028e.kl \
    $(DEVICE_PATH)/configs/keylayout/Vendor_045e_Product_028f.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_045e_Product_028f.kl \
    $(DEVICE_PATH)/configs/keylayout/Vendor_045e_Product_0291.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_045e_Product_0291.kl \
    $(DEVICE_PATH)/configs/keylayout/Vendor_045e_Product_02a1.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_045e_Product_02a1.kl \
    $(DEVICE_PATH)/configs/keylayout/Vendor_045e_Product_02d1.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_045e_Product_02d1.kl \
    $(DEVICE_PATH)/configs/keylayout/Vendor_045e_Product_02e0.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_045e_Product_02e0.kl \
    $(DEVICE_PATH)/configs/keylayout/Vendor_045e_Product_02e3.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_045e_Product_02e3.kl \
    $(DEVICE_PATH)/configs/keylayout/Vendor_045e_Product_02e6.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_045e_Product_02e6.kl \
    $(DEVICE_PATH)/configs/keylayout/Vendor_045e_Product_02ea.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_045e_Product_02ea.kl \
    $(DEVICE_PATH)/configs/keylayout/Vendor_045e_Product_02fd.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_045e_Product_02fd.kl \
    $(DEVICE_PATH)/configs/keylayout/Vendor_045e_Product_0719.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_045e_Product_0719.kl \
    $(DEVICE_PATH)/configs/keylayout/Vendor_045e_Product_0b12.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_045e_Product_0b12.kl \
    $(DEVICE_PATH)/configs/keylayout/Vendor_054c_Product_0268.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_054c_Product_0268.kl \
    $(DEVICE_PATH)/configs/keylayout/Vendor_054c_Product_05c4.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_054c_Product_05c4.kl \
    $(DEVICE_PATH)/configs/keylayout/Vendor_054c_Product_09cc.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_054c_Product_09cc.kl \
    $(DEVICE_PATH)/configs/keylayout/Vendor_054c_Product_0ce6.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_054c_Product_0ce6.kl \
    $(DEVICE_PATH)/configs/keylayout/Vendor_057e_Product_2009.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_057e_Product_2009.kl \
    $(DEVICE_PATH)/configs/keylayout/Vendor_0810_Product_0001.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_0810_Product_0001.kl \
    $(DEVICE_PATH)/configs/keylayout/Vendor_0e6f_Product_f501.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_0e6f_Product_f501.kl \
    $(DEVICE_PATH)/configs/keylayout/Vendor_1038_Product_1412.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_1038_Product_1412.kl \
    $(DEVICE_PATH)/configs/keylayout/Vendor_146b_Product_0d01.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_146b_Product_0d01.kl

# NFC
PRODUCT_PACKAGES += \
    NfcNci \
    Tag \
    SecureElement \
    com.android.nfc_extras

# Overlays
DEVICE_PACKAGE_OVERLAYS += \
    $(DEVICE_PATH)/overlay-lineage

PRODUCT_PACKAGES += \
    AospWifiResOverlayMarble \
    CarrierConfigResCommon \
    FrameworksResCommon \
    FrameworksResOverlayMarble \
    SettingsOverlayMarble \
    SettingsResCommon \
    SystemUIOverlayMarble \
    SystemUIResCommon \
    TelecommResCommon \
    TelephonyResCommon \
    TetheringResCommon \
    WifiResCommon

PRODUCT_PACKAGES += \
    AospWifiResOverlayMarbleChina \
    AospWifiResOverlayMarbleGlobal \
    AospWifiResOverlayMarbleIndia \
    SettingsOverlayGlobal \
    SettingsOverlayChina \
    SettingsOverlayIndia \
    SettingsProviderOverlayChina \
    SettingsProviderOverlayGlobal \
    SettingsProviderOverlayIndia

# Partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true
#PRODUCT_BUILD_SUPER_PARTITION := true

# Parts
PRODUCT_PACKAGES += \
    XiaomiParts

# Power
PRODUCT_PACKAGES += \
    android.hardware.power-service-qti

# Properties
include $(DEVICE_PATH)/configs/properties/default.mk

# RIL
PRODUCT_PACKAGES += \
    Ims \
    QtiTelephony \
    qti-telephony-common

# Perf
PRODUCT_PACKAGES += \
    vendor.qti.hardware.perf@2.3

# Rootdir
PRODUCT_PACKAGES += \
    init.recovery.qcom.rc \
    init.qcom.rc

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(DEVICE_PATH)

# Speed profile services and wifi-service to reduce RAM and storage
PRODUCT_SYSTEM_SERVER_COMPILER_FILTER := speed-profile

# Telephony
PRODUCT_PACKAGES += \
    extphonelib \
    extphonelib-product \
    extphonelib.xml \
    extphonelib_product.xml \
    ims-ext-common \
    ims_ext_common.xml \
    qti-telephony-hidl-wrapper \
    qti-telephony-hidl-wrapper-prd \
    qti_telephony_hidl_wrapper.xml \
    qti_telephony_hidl_wrapper_prd.xml \
    qti-telephony-utils \
    qti-telephony-utils-prd \
    qti_telephony_utils.xml \
    qti_telephony_utils_prd.xml \
    telephony-ext

PRODUCT_BOOT_JARS += \
    telephony-ext

# Update engine
PRODUCT_PACKAGES += \
    checkpoint_gc \
    otapreopt_script \
    update_engine \
    update_engine_sideload \
    update_verifier

PRODUCT_PACKAGES_DEBUG += \
    update_engine_client
