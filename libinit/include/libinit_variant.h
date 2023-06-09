/*
 * Copyright (C) 2021 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef LIBINIT_VARIANT_H
#define LIBINIT_VARIANT_H

#include <string>
#include <vector>

typedef struct variant_info {
    std::string hwc_value;
    std::string sku_value;

    std::string brand;
    std::string device;
    std::string marketname;
    std::string model;
    std::string mod_device;
    std::string build_fingerprint;

} variant_info_t;

void search_variant(const std::vector<variant_info_t> variants);

void set_variant_props(const variant_info_t variant);

#endif // LIBINIT_VARIANT_H
