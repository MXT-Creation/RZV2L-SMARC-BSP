SUMMARY = "RZ/V2L AI Evaluation Software - DRP AI models"
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

SRC_URI = "file://licenses/ \
	   file://hrnet_cam.tar.bz2 \
	   file://resnet50_cam.tar.bz2 \
	   file://tinyyolov2_cam.tar.bz2 \
	   file://yolov3_cam.tar.bz2 \
	   file://coco-labels-2014_2017.txt \
	   file://synset_words_imagenet.txt \
"

MODELS_DIR = "/usr/share/drpai-models/"

do_install() {
	install -d ${D}${MODELS_DIR}/licenses/
	cp -rf ${WORKDIR}/licenses/* ${D}${MODELS_DIR}/licenses/

	install -d ${D}${MODELS_DIR}/hrnet_cam/
	install -d ${D}${MODELS_DIR}/resnet50_cam/
	install -d ${D}${MODELS_DIR}/tinyyolov2_cam/
	install -d ${D}${MODELS_DIR}/yolov3_cam/

	cp -rf ${WORKDIR}/hrnet_cam/* ${D}${MODELS_DIR}/hrnet_cam/
	cp -rf ${WORKDIR}/resnet50_cam/* ${D}${MODELS_DIR}/resnet50_cam/
	cp -rf ${WORKDIR}/tinyyolov2_cam/* ${D}${MODELS_DIR}/tinyyolov2_cam/
	cp -rf ${WORKDIR}/yolov3_cam/* ${D}${MODELS_DIR}/yolov3_cam/

	install -m 0644 ${WORKDIR}/coco-labels-2014_2017.txt ${D}${MODELS_DIR}/
	install -m 0644 ${WORKDIR}/synset_words_imagenet.txt ${D}${MODELS_DIR}/
}

FILES_${PN} = " \
	${MODELS_DIR}/* \
"

