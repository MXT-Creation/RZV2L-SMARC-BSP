#
# Copyright (C) 2021 RenesasElectronics, Co, Ltd.
#
DESCRIPTION = "DRP-AI Support Package with kernel for RZ/V2L Evaluation Board Kit PMIC version"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/:"

SRC_URI_append += "\
	file://0001-ov5645-Add-VGA-720x480-and-720p-resloutions.patch \
	file://0002-ov5645-Add-pixel-rate-support-for-each-mode.patch \
	file://0003-rzg2l-csi-Add-BGR24-and-YUYV-support.patch \
	file://0004-rzg2l-dma-Add-BGR24-and-YUYV-support.patch \
	file://0005-update-ov5645-VGA-setting.patch \
	file://0006-enable-u-dma-buf-function.patch \
	file://0007-enable-drpai-drv.patch \
	file://0008-WA-available-v4l2-memory-userptr.patch \
"