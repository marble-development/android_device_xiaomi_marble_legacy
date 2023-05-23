#
# Copyright (C) 2023 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_DEVICE),marble)
	include $(call all-makefiles-under,$(LOCAL_PATH))
	include $(CLEAR_VARS)
endif
