/*
 * Copyright (C) 2021 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <sys/sysinfo.h>
#include <libinit_utils.h>

#include <libinit_dalvik_heap.h>

#define HEAPSTARTSIZE_PROP "dalvik.vm.heapstartsize"
#define HEAPGROWTHLIMIT_PROP "dalvik.vm.heapgrowthlimit"
#define HEAPSIZE_PROP "dalvik.vm.heapsize"
#define HEAPMINFREE_PROP "dalvik.vm.heapminfree"
#define HEAPMAXFREE_PROP "dalvik.vm.heapmaxfree"
#define HEAPTARGETUTILIZATION_PROP "dalvik.vm.heaptargetutilization"

#define GB(b) (b * 1024ull * 1024 * 1024)

static const dalvik_heap_info_t dalvik_heap_info_16384 = {
    .heapstartsize = "32m",
    .heapgrowthlimit = "448m",
    .heapsize = "640m",
    .heapminfree = "16m",
    .heapmaxfree = "64m",
    .heaptargetutilization = "0.4",
};

static const dalvik_heap_info_t dalvik_heap_info_12288 = {
    .heapstartsize = "24m",
    .heapgrowthlimit = "384m",
    .heapsize = "512m",
    .heapminfree = "8m",
    .heapmaxfree = "56m",
    .heaptargetutilization = "0.42",
};

static const dalvik_heap_info_t dalvik_heap_info_8192 = {
    .heapstartsize = "24m",
    .heapgrowthlimit = "256m",
    .heapsize = "512m",
    .heapminfree = "8m",
    .heapmaxfree = "48m",
    .heaptargetutilization = "0.46",
};

void set_dalvik_heap() {
    struct sysinfo sys;
    const dalvik_heap_info_t *dhi;

    sysinfo(&sys);

    if (sys.totalram > GB(15))
        dhi = &dalvik_heap_info_16384;
    else if (sys.totalram > GB(11))
        dhi = &dalvik_heap_info_12288;
    else
        dhi = &dalvik_heap_info_8192;

    property_override(HEAPSTARTSIZE_PROP, dhi->heapstartsize);
    property_override(HEAPGROWTHLIMIT_PROP, dhi->heapgrowthlimit);
    property_override(HEAPSIZE_PROP, dhi->heapsize);
    property_override(HEAPTARGETUTILIZATION_PROP, dhi->heaptargetutilization);
    property_override(HEAPMINFREE_PROP, dhi->heapminfree);
    property_override(HEAPMAXFREE_PROP, dhi->heapmaxfree);
}
