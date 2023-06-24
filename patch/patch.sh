#!/bin/sh
PATCH_LOC=$PWD/device/xiaomi/marble/patch
cd frameworks/native
git am $PATCH_LOC/frameworks/native/0001-Fix-vibration.patch
cd ../av
git am $PATCH_LOC/frameworks/av/0001-APM-Optionally-force-load-audio-policy-for-system-si.patch
git am $PATCH_LOC/frameworks/av/0002-APM-Remove-A2DP-audio-ports-from-the-primary-HAL.patch
cd ../base
git am $PATCH_LOC/frameworks/base/0001-Revert-Use-getUahDischarge-when-available.patch
cd ../../packages/modules/Bluetooth
git am $PATCH_LOC/packages/modules/Bluetooth/0001-audio_hal_interface-Optionally-use-sysbta-HAL.patch

