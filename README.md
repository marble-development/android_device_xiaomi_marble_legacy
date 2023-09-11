# Device tree for Redmi Note 12 Turbo/Poco F5

Redmi Note 12 Turbo/Poco F5 (codenamed _"marble"_) is a high-end, mid-range smartphone from Xiaomi.

It was announced & released in March 2023.

## Needed patches
Dolby Vision (hardware_qcom_sm8450-caf)
- https://github.com/AOSPA/android_hardware_qcom_display/commit/a1411d27666e5cf2ac8c01e967412812d4384494
- https://github.com/AOSPA/android_hardware_qcom_display/commit/b4095025b66d86635c2ed44d39c72f222803fbb6

FEAS (frameworks_native)
- https://gist.github.com/YuKongA/81924b5685338645ee8e672fe4c2e5a0

HWC (frameworks_native)
- https://github.com/pa-gr/android_frameworks_native/commit/61060ad

LDAC (hardware_interfaces)
- https://github.com/syberia-project/platform_hardware_interfaces/commit/962a90be9d530d652030976857cf758bc8a31556

LTE_CA (frameworks_base)
- https://github.com/AlphaDroid-Project/frameworks_base/commit/b8c21bfa2cc32dde70d3fc6f3bc860fcfbcdc2db
  
Media (frameworks_av)
- https://review.lineageos.org/c/LineageOS/android_frameworks_av/+/342862


## Device specifications

|      Basic | Spec Sheet                                                        |
| ---------: | :---------------------------------------------------------------- |
|        SoC | Snapdragon® 7+ Gen 2 (SM7475-AB)                                  |
|        CPU | Octa-core CPU with 1x Cortex-X2 & 3x Cortex-A710 & 4x Cortex-A510 |
|        GPU | Adreno 725 (580 MHz)                                              |
|     Memory | 8/12/16 GB RAM (LPDDR5)                                           |
| Shipped OS | 13.0 with MIUI 14                                                 |
|    Storage | 256/512/1024 GB (UFS 3.1)                                         |
|    Battery | 5000 mAh, non-removable, 67W fast charge                          |
|    Display | 1080 x 2400 pixels, 20:9 ratio, 6.67 inches, 120 hz, AMOLED       |
|     Camera | 64MP (Primary), 8MP (Ultra-wide), 2MP (Macro)                     |

![Redmi Note 12 Turbo](https://cdn.cnbj0.fds.api.mi-img.com/b2c-shopapi-pms/pms_1679982565.12241762.png)

## Copyright

```
#
# Copyright (C) 2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
