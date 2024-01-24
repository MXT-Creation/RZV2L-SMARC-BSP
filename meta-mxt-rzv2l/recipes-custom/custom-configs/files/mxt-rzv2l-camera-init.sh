#!/bin/sh

if media-ctl -d /dev/media0 -V "'ov5647 1-0036':0 [fmt:SBGGR10_1X10/640x480 field:none]" &> /dev/null ; then
	echo "Using camera is 'ov5647 1-0036':0"
	media-ctl -d /dev/media0 -V "'rzg2l_csi2 10830400.csi2':1 [fmt:SBGGR10_1X10/640x480 field:none]"
	media-ctl -d /dev/media0 -l "'rzg2l_csi2 10830400.csi2':1 -> 'CRU output':0 [1]"

	v4l2-ctl --set-ctrl=gain_automatic=1
	v4l2-ctl --set-ctrl=white_balance_automatic=1
	v4l2-ctl --set-ctrl=auto_exposure=0  # 0 = auto-exposure, 1 = manul

	exit 0
fi

# FIXME: needs testing without ISP
if media-ctl -d /dev/media0 -V "'imx219 1-0010':0 [fmt:SBGGR10_1X10/640x480 field:none]" &> /dev/null ; then
	echo "Using camera is 'imx219 1-0010':0"
	media-ctl -d /dev/media0 -V "'rzg2l_csi2 10830400.csi2':1 [fmt:SBGGR10_1X10/640x480 field:none]"
	media-ctl -d /dev/media0 -l "'rzg2l_csi2 10830400.csi2':1 -> 'CRU output':0 [1]"

	v4l2-ctl --set-ctrl=gain_automatic=1
	v4l2-ctl --set-ctrl=white_balance_automatic=1
	v4l2-ctl --set-ctrl=auto_exposure=0  # 0 = auto-exposure, 1 = manul

	exit 0
fi

# FIXME: needs testing without ISP
if media-ctl -d /dev/media0 -V "'imx296 1-001a':0 [fmt:SBGGR10_1X10/640x480 field:none]" &> /dev/null ; then
	echo "Using camera is 'imx296 1-001a':0"
	media-ctl -d /dev/media0 -V "'rzg2l_csi2 10830400.csi2':1 [fmt:SBGGR10_1X10/640x480 field:none]"
	media-ctl -d /dev/media0 -l "'rzg2l_csi2 10830400.csi2':1 -> 'CRU output':0 [1]"

	v4l2-ctl --set-ctrl=gain_automatic=1
	v4l2-ctl --set-ctrl=white_balance_automatic=1
	v4l2-ctl --set-ctrl=auto_exposure=0  # 0 = auto-exposure, 1 = manul

	exit 0
fi

echo "No supported camera found"
