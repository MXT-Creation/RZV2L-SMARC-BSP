SUMMARY = "RZ/V2L AI Evaluation Software"
SECTION = "app"
LICENSE = "(MIT) & (Apache-2.0) & (PyTorch) & (BSD-3-Clause)"
LIC_FILES_CHKSUM = "file://application_binaries/licenses/keras-vis/LICENSE.txt;md5=7cdaa006daa053917d69f0d7154dea24"
LIC_FILES_CHKSUM = "file://application_binaries/licenses/onnx_tutorials/LICENSE.txt;md5=c594e50eac2ce59950729028841eb01c"
LIC_FILES_CHKSUM = "file://application_binaries/licenses/pytorch/LICENSE.txt;md5=dfcca3a12d86473cf25a596ffe56a645"
LIC_FILES_CHKSUM = "file://application_binaries/licenses/pytorch_vision/LICENSE.txt;md5=2a5939a3a1f3f85f890e8b0488f8d426"


SRC_URI = " \
	file://ai-eva-sw_v7.4.0.tar.bz2 \
"

APP_INSTALL_DIRECTORY ?= "/home/root/RZV_AI_Eva_SW"


S = "${WORKDIR}"

RDEPENDS_${PN} = "jpeg"
DEPENDS = "jpeg"

do_install() {
        install -d ${D}${APP_INSTALL_DIRECTORY}/resnet50_bmp
        install -d ${D}${APP_INSTALL_DIRECTORY}/resnet50_cam
        install -d ${D}${APP_INSTALL_DIRECTORY}/resnet50_jpg
        install -d ${D}${APP_INSTALL_DIRECTORY}/licenses
        install -d ${D}${APP_INSTALL_DIRECTORY}/licenses/keras-vis
        install -d ${D}${APP_INSTALL_DIRECTORY}/licenses/onnx_tutorials
        install -d ${D}${APP_INSTALL_DIRECTORY}/licenses/pytorch
        install -d ${D}${APP_INSTALL_DIRECTORY}/licenses/pytorch_vision
        install -d ${D}${APP_INSTALL_DIRECTORY}/bmp_img
        install -d ${D}${APP_INSTALL_DIRECTORY}/jpg_img
        install -m 0755 ${WORKDIR}/application_binaries/resnet50_bmp/*  ${D}${APP_INSTALL_DIRECTORY}/resnet50_bmp
        install -m 0755 ${WORKDIR}/application_binaries/resnet50_cam/*  ${D}${APP_INSTALL_DIRECTORY}/resnet50_cam
        install -m 0755 ${WORKDIR}/application_binaries/resnet50_jpg/*  ${D}${APP_INSTALL_DIRECTORY}/resnet50_jpg
        install -m 0755 ${WORKDIR}/application_binaries/licenses/keras-vis/*  ${D}${APP_INSTALL_DIRECTORY}/licenses/keras-vis
        install -m 0755 ${WORKDIR}/application_binaries/licenses/onnx_tutorials/*  ${D}${APP_INSTALL_DIRECTORY}/licenses/onnx_tutorials
        install -m 0755 ${WORKDIR}/application_binaries/licenses/pytorch/*  ${D}${APP_INSTALL_DIRECTORY}/licenses/pytorch
        install -m 0755 ${WORKDIR}/application_binaries/licenses/pytorch_vision/*  ${D}${APP_INSTALL_DIRECTORY}/licenses/pytorch_vision
        install -m 0755 ${WORKDIR}/application_binaries/bmp_img/*  ${D}${APP_INSTALL_DIRECTORY}/bmp_img
        install -m 0755 ${WORKDIR}/application_binaries/jpg_img/*  ${D}${APP_INSTALL_DIRECTORY}/jpg_img
        install -m 0755 ${WORKDIR}/application_binaries/rzv_ai_eva_sw  ${D}${APP_INSTALL_DIRECTORY}
        install -m 0755 ${WORKDIR}/application_binaries/start_app.sh  ${D}${APP_INSTALL_DIRECTORY}
        install -m 0755 ${WORKDIR}/application_binaries/config.ini  ${D}${APP_INSTALL_DIRECTORY}
}

FILES_${PN} = " \
    ${APP_INSTALL_DIRECTORY}/* \
"
