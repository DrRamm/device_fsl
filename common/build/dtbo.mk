# Copyright (C) 2018 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

TARGET_KERNEL_ARCH := $(strip $(TARGET_KERNEL_ARCH))
TARGET_KERNEL_SRC := $(KERNEL_IMX_PATH)/kernel_imx
KERNEL_AFLAGS ?=
KERNEL_CFLAGS ?=

ifeq ($(TARGET_KERNEL_ARCH), arm)
KERNEL_SRC_ARCH := arm
DTS_ADDITIONAL_PATH :=
else ifeq ($(TARGET_KERNEL_ARCH), arm64)
KERNEL_SRC_ARCH := arm64
DTS_ADDITIONAL_PATH := freescale
else
$(error kernel arch not supported at present)
endif

MKDTIMG := $(HOST_OUT_EXECUTABLES)/mkdtimg$(HOST_EXECUTABLE_SUFFIX)
DTS_PATH := $(TARGET_KERNEL_SRC)/arch/$(KERNEL_SRC_ARCH)/boot/dts/$(DTS_ADDITIONAL_PATH)/
DTS_SRC :=
$(foreach dts_config,$(TARGET_BOARD_DTS_CONFIG), \
    $(eval DTS_SRC += $(addprefix $(DTS_PATH),$(shell echo ${dts_config} | cut -d':' -f2 | sed 's/dtb/dts/g' ))))

$(BOARD_PREBUILT_DTBOIMAGE): $(KERNEL_BIN) $(DTS_SRC) | $(MKDTIMG) $(AVBTOOL) $(INSTALLED_KERNEL_TARGET)
	$(hide) echo "Building $(KERNEL_ARCH) dtbo ..."
	for dtsplat in $(TARGET_BOARD_DTS_CONFIG); do \
		DTS_PLATFORM=`echo $$dtsplat | cut -d':' -f1`; \
		DTB_NAME=`echo $$dtsplat | cut -d':' -f2`; \
		DTB=`echo $(PRODUCT_OUT)/obj/KERNEL_OBJ/arch/$(TARGET_KERNEL_ARCH)/boot/dts/$(DTS_ADDITIONAL_PATH)/$${DTB_NAME}`; \
		DTBO_IMG=`echo $(PRODUCT_OUT)/dtbo-$${DTS_PLATFORM}.img`; \
		$(MKDTIMG) create $$DTBO_IMG $$DTB; \
		$(AVBTOOL) add_hash_footer --image $$DTBO_IMG  \
			--partition_name dtbo \
			--partition_size $(BOARD_DTBOIMG_PARTITION_SIZE); \
	done

.PHONY: dtboimage
dtboimage: $(BOARD_PREBUILT_DTBOIMAGE)
