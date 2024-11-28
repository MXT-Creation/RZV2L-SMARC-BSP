SUMMARY = "RZ/V AI Evaluation Software - App CAM via HTTP"
SECTION = "app"
# Not CLOSED, but we also don't want to bother with a license file now
LICENSE = "CLOSED"
#LIC_FILES_CHKSUM = ""

inherit systemd
inherit cmake

SRC_URI = "file://src/ \
	   file://licenses/ \
	   file://app-usbcam-http.service \
"

DEPENDS += " drpai libjpeg-turbo opencv "

RDEPENDS_${PN} += " drpai-models "

APP_INSTALL_DIRECTORY ?= "/home/root/app-usbcam-http"

S = "${WORKDIR}/src"

do_install() {
	install -d ${D}${APP_INSTALL_DIRECTORY}
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

