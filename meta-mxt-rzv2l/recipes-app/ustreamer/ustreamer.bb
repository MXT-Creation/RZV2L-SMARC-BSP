SUMMARY = "µStreamer - Lightweight and fast MJPEG-HTTP streamer"
SECTION = "app"
LICENSE = "INCOMPATIBLE"
#" GPL-3.0 license"
LIC_FILES_CHKSUM = " \
	file://LICENSE;md5=d32239bcb673463ab874e80d47fae504 \
"

inherit systemd

PV = "6.7"

SRC_URI = " \
	https://codeload.github.com/pikvm/ustreamer/tar.gz/v${PV}?${BPN}-${PV}.tar.gz \
	file://ustreamer@.service \
"

SRC_URI[sha256sum] = "51a8a974d55d5139a86c055df63b99e90e31e9d6af62f69b2decccdb02a29092"

DEPENDS += " libbsd libevent libjpeg-turbo "

do_install() {
	install -m 0755 -d ${D}${bindir}
	install -m 0755 ${S}/src/ustreamer.bin ${D}${bindir}/ustreamer

	install -m 0755 -d ${D}${systemd_unitdir}/system
	install -m 0644 ${WORKDIR}/ustreamer@.service ${D}${systemd_unitdir}/system/
}

SYSTEMD_AUTO_ENABLE = "disable"
SYSTEMD_SERVICE_${PN} = "ustreamer@.service"

FILES_${PN} = " \
	${systemd_unitdir}/* \
	${bindir}/* \
"
