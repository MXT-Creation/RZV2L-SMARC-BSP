#!/bin/sh

rm -f /tmp/app-usbcam-http-config

if media-ctl -d /dev/media0 -V "'tevs 0-0048':0 [fmt:UYVY8_2X8/640x480 field:none]" &> /dev/null ; then
	echo "Using camera is 'tevs 0-0048':0"
	media-ctl -d /dev/media0 -V "'rzg2l_csi2 10830400.csi2':1 [fmt:UYVY8_2X8/640x480 field:none]"
	media-ctl -d /dev/media0 -l "'rzg2l_csi2 10830400.csi2':1 -> 'CRU output':0 [1]"

	exit 0
fi

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

if media-ctl -d /dev/media0 -V "'imx708_noir':0 [fmt:SRGGB10_1X10/1536x864 field:none]" &> /dev/null ; then
	echo "Using camera is 'imx708_noir':0"
	media-ctl -d /dev/media0 -V "'rzg2l_csi2 10830400.csi2':1 [fmt:SSRGGB10_1X10/1536x864 field:none]"
	media-ctl -d /dev/media0 -l "'rzg2l_csi2 10830400.csi2':1 -> 'CRU output':0 [1]"

	v4l2-ctl --set-ctrl=digital_gain=2000
	v4l2-ctl --set-ctrl=analogue_gain=700

	exit 0
fi

if media-ctl -d /dev/media0 -V "'arducam-pivariety 1-000c':0 [fmt:SRGGB10_1X10/1920x1080 field:none]" &> /dev/null ; then
	echo "Using camera is 'arducam-pivariety 1-000c':0"
	media-ctl -d /dev/media0 -V "'rzg2l_csi2 10830400.csi2':1 [fmt:SRGGB10_1X10/1920x1080 field:none]"
	media-ctl -d /dev/media0 -l "'rzg2l_csi2 10830400.csi2':1 -> 'CRU output':0 [1]"

	exit 0
fi

if media-ctl -d /dev/media0 -V "'ov13850 0-0036':0 [fmt:SBGGR10_1X10/2112x1568 field:none crop:(96,244)/1920x1080]" &> /dev/null ; then
	echo "Using camera is 'ov13850 0-0036':0"
	media-ctl -d /dev/media0 -V "'rzg2l_csi2 10830400.csi2':1 [fmt:SBGGR10_1X10/1920x1080 field:none]"
	media-ctl -d /dev/media0 -l "'rzg2l_csi2 10830400.csi2':1 -> 'CRU output':0 [1]"

	v4l2-ctl --set-ctrl=analogue_gain=500

	echo "NATIVE_CAMERA_IMAGE_WIDTH=1920" >> /tmp/app-usbcam-http-config
	echo "NATIVE_CAMERA_IMAGE_HEIGHT=1080" >> /tmp/app-usbcam-http-config

	exit 0
fi

echo "No supported camera found"
