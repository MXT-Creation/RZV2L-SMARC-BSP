SUMMARY = "RZ/V AI Evaluation Software - Client Software"
SECTION = "app"
LICENSE = "MIT&Apache&BSD-3-Clause"
LIC_FILES_CHKSUM = " \
"

SRC_URI = "file://Websocket_Client/ \
"

RDEPENDS_${PN} += " sthttpd "

do_install() {
	install -d ${D}${servicedir}/www/
	cp -rf ${WORKDIR}/Websocket_Client/* ${D}${servicedir}/www/
}

FILES_${PN} = " \
	${servicedir}/www/ \
"
