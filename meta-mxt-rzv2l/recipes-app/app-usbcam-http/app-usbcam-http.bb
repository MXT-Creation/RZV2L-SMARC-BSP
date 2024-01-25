SUMMARY = "RZ/V AI Evaluation Software - App CAM via HTTP"
SECTION = "app"
LICENSE = "MIT&Apache&BSD-3-Clause"
LIC_FILES_CHKSUM = " \
    file://../licenses/coco-labels/LICENSE.txt;md5=64c73cecafee947f9f003c2d834979df \
    file://../licenses/keras-vis/LICENSE.txt;md5=7cdaa006daa053917d69f0d7154dea24 \
    file://../licenses/mmpose/LICENSE.txt;md5=843c07ca380ea0e8352bf03f67219a2b \
    file://../licenses/onnx_tutorials/LICENSE.txt;md5=c594e50eac2ce59950729028841eb01c \
    file://../licenses/pytorch/LICENSE.txt;md5=dfcca3a12d86473cf25a596ffe56a645 \
    file://../licenses/pytorch_vision/LICENSE.txt;md5=2a5939a3a1f3f85f890e8b0488f8d426 \
    file://../licenses/pytorch-yolov3/LICENSE.txt;md5=bf5c8686e8caf36392c2b5c669795be6 \
"

inherit systemd
inherit cmake

SRC_URI = "file://src/ \
	   file://licenses/ \
	   file://app-usbcam-http.service \
	   file://hrnet_cam.tar.bz2 \
	   file://resnet50_cam.tar.bz2 \
	   file://tinyyolov2_cam.tar.bz2 \
	   file://yolov3_cam.tar.bz2 \
	   file://coco-labels-2014_2017.txt \
	   file://synset_words_imagenet.txt \
"

DEPENDS += " drpai libjpeg-turbo "

APP_INSTALL_DIRECTORY ?= "/home/root/app-usbcam-http"

S = "${WORKDIR}/src"

do_install() {
	install -d ${D}${APP_INSTALL_DIRECTORY}/licenses/
	cp -rf ${WORKDIR}/licenses/* ${D}${APP_INSTALL_DIRECTORY}/licenses/

	install -d ${D}${APP_INSTALL_DIRECTORY}/hrnet_cam/
	install -d ${D}${APP_INSTALL_DIRECTORY}/resnet50_cam/
	install -d ${D}${APP_INSTALL_DIRECTORY}/tinyyolov2_cam/
	install -d ${D}${APP_INSTALL_DIRECTORY}/yolov3_cam/

	cp -rf ${WORKDIR}/hrnet_cam/* ${D}${APP_INSTALL_DIRECTORY}/hrnet_cam/
	cp -rf ${WORKDIR}/resnet50_cam/* ${D}${APP_INSTALL_DIRECTORY}/resnet50_cam/
	cp -rf ${WORKDIR}/tinyyolov2_cam/* ${D}${APP_INSTALL_DIRECTORY}/tinyyolov2_cam/
	cp -rf ${WORKDIR}/yolov3_cam/* ${D}${APP_INSTALL_DIRECTORY}/yolov3_cam/

	install -m 0644 ${WORKDIR}/coco-labels-2014_2017.txt ${D}${APP_INSTALL_DIRECTORY}/
	install -m 0644 ${WORKDIR}/synset_words_imagenet.txt ${D}${APP_INSTALL_DIRECTORY}/
	install -m 0755 ${WORKDIR}/build/sample_app_usbcam_http ${D}${APP_INSTALL_DIRECTORY}/

	install -m 0755 -d ${D}${systemd_unitdir}/system
	install -m 0644 ${WORKDIR}/app-usbcam-http.service ${D}${systemd_unitdir}/system/
}

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE_${PN} = "app-usbcam-http.service"

FILES_${PN} = " \
	${systemd_unitdir}/* \
	${APP_INSTALL_DIRECTORY}/* \
"

