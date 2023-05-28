#!/usr/bin/bash
#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

if [[ -z ${1} ]]; then
    echo usage: update_rro.sh /path/to/dump
    exit
fi
dump_path=${1}

# List of rros in product without a theme
product_rros=" \
    CarrierConfigResCommon_Sys \
    FrameworksResCommon_Sys \
    SettingsResCommon_Sys \
    SystemUIResCommon_Sys \
    TelecommResCommon_Sys \
    TelephonyResCommon_Sys \
    WifiResCommon_Sys \
"

# List of rros in vendor without a theme
vendor_rros=" \
    FrameworksResTarget_Vendor \
    WifiResTarget \
    WifiResTarget_spf \
"

function generate_rro () {
    local path=${1}
    bash rro_overlays/generate_rro.sh ${path}
    bash rro_overlays/beautify_rro.sh rro_overlays/$(basename ${path} | sed "s/.apk//g")
}

for rro in ${product_rros}; do
    echo $rro
    rm -rf rro_overlays/${rro}
    generate_rro ${dump_path}/product/overlay/${rro}.apk
done

for rro in ${vendor_rros}; do
    echo $rro
    rm -rf rro_overlays/${rro}
    generate_rro ${dump_path}/vendor/overlay/${rro}.apk
done
