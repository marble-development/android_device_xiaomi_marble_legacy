/*
 * Copyright (C) 2021-2022 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <libinit_dalvik_heap.h>
#include <libinit_variant.h>
#include <libinit_utils.h>

#include "vendor_init.h"

#define FINGERPRINT_GL "POCO/marble_global/marble:13/SKQ1.221022.001/V14.0.1.0.TMRMIXM:user/release-keys"
#define FINGERPRINT_CN "Xiaomi/marble/marble:13/SKQ1.221022.001/V14.0.19.0.TMRCNXM:user/release-keys"
#define FINGERPRINT_IN "POCO/marblein/marblein:13/SKQ1.221022.001/V14.0.1.0.TMRMIXM:user/release-keys"

static const variant_info_t marble_global_info = {
    .hwc_value = "GL",
    .sku_value = "",

    .brand = "POCO",
    .device = "marble",
    .marketname = "POCO F5",
    .model = "23049PCD8G",
    .mod_device = "marble_global",
    .build_fingerprint = FINGERPRINT_GL,
};

static const variant_info_t marblein_info = {
    .hwc_value = "IN",
    .sku_value = "",

    .brand = "POCO",
    .device = "marblein",
    .marketname = "POCO F5",
    .model = "23049PCD8I",
    .mod_device = "marble_in_global",
    .build_fingerprint = FINGERPRINT_IN,
};

static const variant_info_t marble_info = {
    .hwc_value = "",
    .sku_value = "",

    .brand = "Xiaomi",
    .device = "marble",
    .marketname = "Redmi Note 12 Turbo",
    .model = "23049RAD8C",
    .mod_device = "marble",
    .build_fingerprint = FINGERPRINT_CN,
};

static const std::vector<variant_info_t> variants = {
    marble_global_info,
    marblein_info,
    marble_info,
};

void vendor_load_properties() {
    set_dalvik_heap();
    search_variant(variants);

    // SafetyNet workaround
    property_override("ro.boot.verifiedbootstate", "green");
}
