FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

KERNEL_DEVICETREE = " \
	renesas/r9a07g054l2-smarc.dtb \
"

SRC_URI_append +=  "\
	file://fragment-01-usb-ethernet.cfg \
	file://fragment-02-wifi.cfg \
	file://fragment-03-can.cfg \
	file://fragment-04-ov5647.cfg \
	file://fragment-05-imx219.cfg \
	file://fragment-06-mscc-phy.cfg \
	file://patches/0002-media-ov5647-Add-support-for-PWDN-GPIO.patch \
	file://patches/0003-media-ov5647-Add-support-for-non-continuous-clock-mo.patch \
	file://patches/0004-media-ov5647-Add-set_fmt-and-get_fmt-calls.patch \
	file://patches/0005-media-ov5647-Fix-format-initialization.patch \
	file://patches/0006-media-ov5647-Fix-style-issues.patch \
	file://patches/0007-media-ov5647-Replace-license-with-SPDX-identifier.patch \
	file://patches/0008-media-ov5647-Fix-return-value-from-read-write.patch \
	file://patches/0009-media-ov5647-Program-mode-at-s_stream-1-time.patch \
	file://patches/0010-media-ov5647-Implement-enum_frame_size.patch \
	file://patches/0011-media-ov5647-Protect-s_stream-with-mutex.patch \
	file://patches/0012-media-ov5647-Support-gain-exposure-and-AWB-controls.patch \
	file://patches/0013-media-ov5647-Rationalize-driver-structure-name.patch \
	file://patches/0014-media-ov5647-Break-out-format-handling.patch \
	file://patches/0015-media-ov5647-Add-support-for-get_selection.patch \
	file://patches/0016-media-ov5647-Rename-SBGGR8-VGA-mode.patch \
	file://patches/0017-media-ov5647-Add-SGGBR10_1X10-modes.patch \
	file://patches/0018-media-ov5647-Use-SBGGR10_1X10-640x480-as-default.patch \
	file://patches/0019-media-ov5647-Implement-set_fmt-pad-operation.patch \
	file://patches/0020-media-ov5647-Set-V4L2_SUBDEV_FL_HAS_EVENTS-flag.patch \
	file://patches/0021-media-ov5647-Support-V4L2_CID_PIXEL_RATE.patch \
	file://patches/0022-media-ov5647-Support-V4L2_CID_HBLANK-control.patch \
	file://patches/0023-media-ov5647-Support-V4L2_CID_VBLANK-control.patch \
	file://patches/0024-media-ov5647-Advertise-the-correct-exposure-range.patch \
	file://patches/0025-media-ov5647-Use-pm_runtime-infrastructure.patch \
	file://patches/0026-media-ov5647-Rework-s_stream-operation.patch \
	file://patches/0027-media-ov5647-Apply-controls-only-when-powered.patch \
	file://patches/0028-media-ov5647-Constify-oe_enable-disable-reglist.patch \
	file://patches/0029-media-ov5647-Support-VIDIOC_SUBSCRIBE_EVENT.patch \
	file://patches/0030-media-ov5647-Remove-640x480-SBGGR8-mode.patch \
	file://patches/0031-media-i2c-ov5647-use-pm_runtime_resume_and_get.patch \
	file://patches/1001_rzg2l-smarc-pinfunction.patch \
	file://patches/1002_rzg2l-smarc.patch \
	file://patches/1003_rzg2l-smarc-som.patch \
	file://patches/1004_rz-smarc-common.patch \
"

