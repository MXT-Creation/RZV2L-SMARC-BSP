#!/bin/sh

if media-ctl -d /dev/media0 -V "'ov5647 0-0036':0 [fmt:SBGGR10_1X10/640x480 field:none]" &> /dev/null ; then
	echo "Using camera is 'ov5647 0-0036':0"
	media-ctl -d /dev/media0 -V "'rzg2l_csi2 10830400.csi2':1 [fmt:SBGGR10_1X10/640x480 field:none]"
	media-ctl -d /dev/media0 -l "'rzg2l_csi2 10830400.csi2':1 -> 'CRU output':0 [1]"

	v4l2-ctl --set-ctrl=gain_automatic=1
	v4l2-ctl --set-ctrl=white_balance_automatic=1
	v4l2-ctl --set-ctrl=auto_exposure=0  # 0 = auto-exposure, 1 = manul

	exit 0
fi

if media-ctl -d /dev/media0 -V "'imx219 0-0010':0 [fmt:SRGGB10_1X10/640x480 field:none]" &> /dev/null ; then
	echo "Using camera is 'imx219 -0010':0"
	media-ctl -d /dev/media0 -V "'rzg2l_csi2 10830400.csi2':1 [fmt:SRGGB10_1X10/640x480 field:none]"
	media-ctl -d /dev/media0 -l "'rzg2l_csi2 10830400.csi2':1 -> 'CRU output':0 [1]"

	# IMX 219 does not have any controls for automatic gain or auto-exposure, or auto-white-balance
	# We just get these 2 (digital & analogue) gain controls; we'll set some reasonable defaults here
	# root@smarc-rzv2l:~# v4l2-ctl --all | grep gain
	#          analogue_gain 0x009e0903 (int)    : min=0 max=232 step=1 default=0 value=128
	#           digital_gain 0x009f0905 (int)    : min=256 max=4095 step=1 default=256 value=2047

	v4l2-ctl --set-ctrl=digital_gain=2000
	v4l2-ctl --set-ctrl=analogue_gain=200

	exit 0
fi

# FIXME: needs testing without ISP
if media-ctl -d /dev/media0 -V "'imx296 0-001a':0 [fmt:SBGGR10_1X10/640x480 field:none]" &> /dev/null ; then
	echo "Using camera is 'imx296 0-001a':0"
	media-ctl -d /dev/media0 -V "'rzg2l_csi2 10830400.csi2':1 [fmt:SBGGR10_1X10/640x480 field:none]"
	media-ctl -d /dev/media0 -l "'rzg2l_csi2 10830400.csi2':1 -> 'CRU output':0 [1]"

	v4l2-ctl --set-ctrl=gain_automatic=1
	v4l2-ctl --set-ctrl=white_balance_automatic=1
	v4l2-ctl --set-ctrl=auto_exposure=0  # 0 = auto-exposure, 1 = manul

	exit 0
fi

echo "No supported camera found"
