SUMMARY = "Custom configuration files for the board"
SECTION = "custom"
LICENSE = "None"
LIC_FILES_CHKSUM = " \
"

inherit systemd

SRC_URI = "file://connman_main.conf \
	file://mxt-camera-init.sh \
	file://mxt-camera-init.service \
"

do_install() {
	install -m 0755 -d ${D}/etc/connman
	install -m 0744 ${WORKDIR}/connman_main.conf ${D}/etc/connman/main.conf

	install -m 0755 -d ${D}/usr/bin
	install -m 0755 ${WORKDIR}/mxt-camera-init.sh ${D}/usr/bin

	install -m 0755 -d ${D}${systemd_unitdir}/system
	install -m 0744 ${WORKDIR}/mxt-camera-init.service ${D}${systemd_unitdir}/system/
}

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE_${PN} = "mxt-camera-init.service"

FILES_${PN} = " \
	${systemd_unitdir}/* \
	/usr/bin/* \
	/etc/* \
"
