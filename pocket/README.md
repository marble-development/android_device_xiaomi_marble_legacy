[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)&nbsp;[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://paypal.me/maytinhdibo)
# Battery-friendly Pocketmode

## Authors
[Trần Mạnh Cường (Cuong Tran)](https://github.com/maytinhdibo)

## Note
Unlike the traditional pocket mode that constantly checks the proximity and light sensors, this mode only checks them when the phone is in lockscreen. Therefore, the battery life will be extended and deep sleep mode will be optimised.

In case the screen automatically turns off after being taken out of the pocket, please wait for a few seconds and everything will work again.

## How to use
Define two line in device tree source `device.mk`
```
PRODUCT_PACKAGES += \
    PocketMode
    ...
PRODUCT_COPY_FILES += \
     $(LOCAL_PATH)/pocket/privapp-permissions-pocketmode.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-pocketmode.xml
```
And add to this repo into `pocket` folder.
