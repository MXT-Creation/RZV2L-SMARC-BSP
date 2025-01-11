#!/bin/sh

rm -f /tmp/app-usbcam-http-config

CAMERA_FOUND=0

get_csi2_dev() {
	id=$(media-ctl -d "$1" -p | grep entity | grep rzg2l_csi2 | cut -d' ' -f5)
	echo -n "rzg2l_csi2 $id"
}

get_sensor_dev() {
	id=$(media-ctl -d "$1" -p | grep entity | grep $2 | cut -d: -f2 | cut -d'(' -f1 | awk '{$1=$1;print}')
	[ -n "$id" ] || return 1
	echo -n "$id"
}

for MEDIA_DEV in /dev/media* ; do
	CSI2_DEV="'$(get_csi2_dev $MEDIA_DEV)':1"
	CRU_OUTPUT="'CRU output':0 [1]"

	SENSOR_DEV=$(get_sensor_dev $MEDIA_DEV imx135)
	if [ -n "$SENSOR_DEV" ] ; then
		if media-ctl -d /dev/media0 -V "'$SENSOR_DEV':0 [fmt:SRGGB10_1X10/1280x720 field:none]" &> /dev/null ; then
			echo "Using sensor '$SENSOR_DEV'"
			media-ctl -d $MEDIA_DEV -V "${CSI2_DEV} [fmt:SRGGB10_1X10/1280x720 field:none]"
			media-ctl -d $MEDIA_DEV -l "${CSI2_DEV} -> ${CRU_OUTPUT}"

			echo 'NATIVE_CAMERA_IMAGE_WIDTH=1280' > /tmp/app-usbcam-http-config
			echo 'NATIVE_CAMERA_IMAGE_HEIGHT=720' >> /tmp/app-usbcam-http-config

			v4l2-ctl --set-ctrl=digital_gain=4
			v4l2-ctl --set-ctrl=analogue_gain=140
			v4l2-ctl --set-ctrl=exposure=3000

			CAMERA_FOUND=1
			continue
		fi
	fi

	SENSOR_DEV=$(get_sensor_dev $MEDIA_DEV ar0331)
	if [ -n "$SENSOR_DEV" ] ; then
		if media-ctl -d /dev/media0 -V "'$SENSOR_DEV':0 [fmt:SRGGB10_1X10/1280x720 field:none]" &> /dev/null ; then
			echo "Using sensor '$SENSOR_DEV'"
			media-ctl -d $MEDIA_DEV -V "${CSI2_DEV} [fmt:SRGGB10_1X10/1280x720 field:none]"
			media-ctl -d $MEDIA_DEV -l "${CSI2_DEV} -> ${CRU_OUTPUT}"

			echo 'NATIVE_CAMERA_IMAGE_WIDTH=1280' > /tmp/app-usbcam-http-config
			echo 'NATIVE_CAMERA_IMAGE_HEIGHT=720' >> /tmp/app-usbcam-http-config

			CAMERA_FOUND=1
			continue
		fi
	fi

	SENSOR_DEV=$(get_sensor_dev $MEDIA_DEV IMX274)
	if [ -n "$SENSOR_DEV" ] ; then
		if media-ctl -d $MEDIA_DEV -V "'$SENSOR_DEV':0 [fmt:SRGGB10_1X10/1920x1080@1/15]" &> /dev/null ; then
			echo "Using sensor '$SENSOR_DEV'"
			media-ctl -d $MEDIA_DEV -V "${CSI2_DEV} [fmt:SRGGB10_1X10/1920x1080 field:none]"
			media-ctl -d $MEDIA_DEV -l "${CSI2_DEV} -> ${CRU_OUTPUT}"

			v4l2-ctl --set-ctrl=exposure=5000
			v4l2-ctl --set-ctrl=gain=20000

			echo "NATIVE_CAMERA_IMAGE_WIDTH=1920" > /tmp/app-usbcam-http-config
			echo "NATIVE_CAMERA_IMAGE_HEIGHT=1080" >> /tmp/app-usbcam-http-config

			CAMERA_FOUND=1
			continue
		fi
	fi

	SENSOR_DEV=$(get_sensor_dev $MEDIA_DEV imx377)
	if [ -n "$SENSOR_DEV" ] ; then
		if media-ctl -d $MEDIA_DEV -V "'$SENSOR_DEV':0 [fmt:SRGGB10_1X10/3912x2176 crop:(972,516)/1920x1080]" &> /dev/null ; then
			echo "Using sensor '$SENSOR_DEV'"
			media-ctl -d $MEDIA_DEV -V "${CSI2_DEV} [fmt:SRGGB10_1X10/1920x1080 field:none]"
			media-ctl -d $MEDIA_DEV -l "${CSI2_DEV} -> ${CRU_OUTPUT}"

			echo "NATIVE_CAMERA_IMAGE_WIDTH=1920" > /tmp/app-usbcam-http-config
			echo "NATIVE_CAMERA_IMAGE_HEIGHT=1080" >> /tmp/app-usbcam-http-config

			CAMERA_FOUND=1
			continue
		fi
	fi

	SENSOR_DEV=$(get_sensor_dev $MEDIA_DEV ov13850)
	if [ -n "$SENSOR_DEV" ] ; then
		if media-ctl -d $MEDIA_DEV -V "'$SENSOR_DEV':0 [fmt:SBGGR10_1X10/2112x1568 field:none crop:(96,244)/1920x1080]" &> /dev/null ; then
			echo "Using sensor '$SENSOR_DEV'"
			media-ctl -d $MEDIA_DEV -V "${CSI2_DEV} [fmt:SBGGR10_1X10/1920x1080 field:none]"
			media-ctl -d $MEDIA_DEV -l "${CSI2_DEV} -> ${CRU_OUTPUT}"

			v4l2-ctl --set-ctrl=analogue_gain=500

			echo "NATIVE_CAMERA_IMAGE_WIDTH=1920" > /tmp/app-usbcam-http-config
			echo "NATIVE_CAMERA_IMAGE_HEIGHT=1080" >> /tmp/app-usbcam-http-config

			CAMERA_FOUND=1
			continue
		fi
	fi

	SENSOR_DEV=$(get_sensor_dev $MEDIA_DEV tevs)
	if [ -n "$SENSOR_DEV" ] ; then
		if media-ctl -d $MEDIA_DEV -V "'$SENSOR_DEV':0 [fmt:UYVY8_2X8/640x480 field:none]" &> /dev/null ; then
			echo "Using sensor '$SENSOR_DEV'"
			media-ctl -d $MEDIA_DEV -V "${CSI2_DEV} [fmt:UYVY8_2X8/640x480 field:none]"
			media-ctl -d $MEDIA_DEV -l "${CSI2_DEV} -> ${CRU_OUTPUT}"

			CAMERA_FOUND=1
			continue
		fi
	fi

	SENSOR_DEV=$(get_sensor_dev $MEDIA_DEV imx415)
	if [ -n "$SENSOR_DEV" ] ; then
		if media-ctl -d $MEDIA_DEV -V "'$SENSOR_DEV':0 [fmt:SGBRG10_1X10/1920x1080 field:none]" &> /dev/null ; then
			echo "Using sensor '$SENSOR_DEV'"
			media-ctl -d $MEDIA_DEV -V "${CSI2_DEV} [fmt:SGBRG10_1X10/1920x1080 field:none]"
			media-ctl -d $MEDIA_DEV -l "${CSI2_DEV} -> ${CRU_OUTPUT}"

			v4l2-ctl --set-ctrl=analogue_gain=300
			v4l2-ctl --set-ctrl=exposure=700

			echo "NATIVE_CAMERA_IMAGE_WIDTH=1920" > /tmp/app-usbcam-http-config
			echo "NATIVE_CAMERA_IMAGE_HEIGHT=1080" >> /tmp/app-usbcam-http-config

			CAMERA_FOUND=1
			continue
		fi
	fi

	SENSOR_DEV=$(get_sensor_dev $MEDIA_DEV ov5647)
	if [ -n "$SENSOR_DEV" ] ; then
		if media-ctl -d $MEDIA_DEV -V "'$SENSOR_DEV':0 [fmt:SBGGR10_1X10/640x480 field:none]" &> /dev/null ; then
			echo "Using sensor '$SENSOR_DEV'"
			media-ctl -d $MEDIA_DEV -V "${CSI2_DEV} [fmt:SBGGR10_1X10/640x480 field:none]"
			media-ctl -d $MEDIA_DEV -l "${CSI2_DEV} -> ${CRU_OUTPUT}"

			v4l2-ctl --set-ctrl=gain_automatic=1
			v4l2-ctl --set-ctrl=white_balance_automatic=1
			v4l2-ctl --set-ctrl=auto_exposure=0  # 0 = auto-exposure, 1 = manul

			CAMERA_FOUND=1
			continue
		fi
	fi

	SENSOR_DEV=$(get_sensor_dev $MEDIA_DEV imx219)
	if [ -n "$SENSOR_DEV" ] ; then
		if media-ctl -d $MEDIA_DEV -V "'$SENSOR_DEV':0 [fmt:SRGGB10_1X10/640x480 field:none]" &> /dev/null ; then
			echo "Using sensor '$SENSOR_DEV'"
			media-ctl -d $MEDIA_DEV -V "${CSI2_DEV} [fmt:SRGGB10_1X10/640x480 field:none]"
			media-ctl -d $MEDIA_DEV -l "${CSI2_DEV} -> ${CRU_OUTPUT}"

			# IMX 219 does not have any controls for automatic gain or auto-exposure, or auto-white-balance
			# We just get these 2 (digital & analogue) gain controls; we'll set some reasonable defaults here
			# root@smarc-rzv2l:~# v4l2-ctl --all | grep gain
			#          analogue_gain 0x009e0903 (int)    : min=0 max=232 step=1 default=0 value=128
			#           digital_gain 0x009f0905 (int)    : min=256 max=4095 step=1 default=256 value=2047

			v4l2-ctl --set-ctrl=digital_gain=2000
			v4l2-ctl --set-ctrl=analogue_gain=200

			CAMERA_FOUND=1
			continue
		fi
	fi

	SENSOR_DEV=$(get_sensor_dev $MEDIA_DEV imx296)
	if [ -n "$SENSOR_DEV" ] ; then
		if media-ctl -d $MEDIA_DEV -V "'$SENSOR_DEV':0 [fmt:SBGGR10_1X10/1456x1088 field:none crop:(408,304)/640x480]" &> /dev/null ; then
			echo "Using sensor '$SENSOR_DEV'"
			media-ctl -d $MEDIA_DEV -V "${CSI2_DEV} [fmt:SBGGR10_1X10/640x480 field:none]"
			media-ctl -d $MEDIA_DEV -l "${CSI2_DEV} -> ${CRU_OUTPUT}"

			v4l2-ctl --set-ctrl=exposure=500
			v4l2-ctl --set-ctrl=analogue_gain=200

			CAMERA_FOUND=1
			continue
		fi
	fi

	SENSOR_DEV=$(get_sensor_dev $MEDIA_DEV imx708_noir)
	if [ -n "$SENSOR_DEV" ] ; then
		if media-ctl -d $MEDIA_DEV -V "'$SENSOR_DEV':0 [fmt:SRGGB10_1X10/1536x864 field:none]" &> /dev/null ; then
			echo "Using sensor '$SENSOR_DEV'"

			echo 'NATIVE_CAMERA_IMAGE_WIDTH=1536' > /tmp/app-usbcam-http-config
			echo 'NATIVE_CAMERA_IMAGE_HEIGHT=864' >> /tmp/app-usbcam-http-config

			media-ctl -d $MEDIA_DEV -V "${CSI2_DEV} [fmt:SSRGGB10_1X10/1536x864 field:none]"
			media-ctl -d $MEDIA_DEV -l "${CSI2_DEV} -> ${CRU_OUTPUT}"

			v4l2-ctl --set-ctrl=digital_gain=2000
			v4l2-ctl --set-ctrl=analogue_gain=700

			CAMERA_FOUND=1
			continue
		fi
	fi

	SENSOR_DEV=$(get_sensor_dev $MEDIA_DEV arducam-pivariety)
	if [ -n "$SENSOR_DEV" ] ; then
		if media-ctl -d $MEDIA_DEV -V "'$SENSOR_DEV':0 [fmt:SRGGB10_1X10/1920x1080 field:none]" &> /dev/null ; then
			echo "Using sensor '$SENSOR_DEV'"

			echo 'NATIVE_CAMERA_IMAGE_WIDTH=1920' > /tmp/app-usbcam-http-config
			echo 'NATIVE_CAMERA_IMAGE_HEIGHT=1080' >> /tmp/app-usbcam-http-config

			media-ctl -d $MEDIA_DEV -V "${CSI2_DEV} [fmt:SRGGB10_1X10/1920x1080 field:none]"
			media-ctl -d $MEDIA_DEV -l "${CSI2_DEV} -> ${CRU_OUTPUT}"

			v4l2-ctl --set-ctrl=analogue_gain=10000

			CAMERA_FOUND=1
			continue
		fi
	fi

done

[ "$CAMERA_FOUND" = "1" ] || echo "No supported camera found"
