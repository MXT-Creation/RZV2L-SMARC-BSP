#
# This recipe adds DA16600 wifi module driver to RZ/V2L SDK environment.
#
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

inherit module

DESCRIPTION = "Recipe for DA16600 wifi module driver"
LICENSE = "CLOSED"

PACKAGE_ARCH = "${MACHINE_ARCH}"
PACKAGES = "${PN}"
PROVIDES = "${PN}"

DEPENDS = " linux-renesas"

PR = "r1"

SRC_URI_append += " \
	file://da16200_v5.2.1.2.tar.gz \
	file://lmacfw_spi.bin \
"

FILES_${PN} += " \
	/lib/firmware/lmacfw_spi.bin \
	/lib/modules/${KERNEL_VERSION}/extra/rswlan.ko \
"

S = "${WORKDIR}/rswlan"

EXTRA_OEMAKE += "KDIR='${STAGING_KERNEL_DIR}'"
EXTRA_OEMAKE += "CONFIG_RS_BCN=y"
EXTRA_OEMAKE += "CONFIG_HOST_TX_MERGE=y"
EXTRA_OEMAKE += "CONFIG_MODULE_TYPE=spi"

do_install() {
	install -m 0755 -d ${D}/lib/firmware
	install -m 0644 ${WORKDIR}/lmacfw_spi.bin ${D}/lib/firmware/lmacfw_spi.bin

	install -m 0755 -d ${D}/lib/modules/${KERNEL_VERSION}/extra
	install -m 0644 ${WORKDIR}/rswlan/rswlan.ko ${D}/lib/modules/${KERNEL_VERSION}/extra/rswlan.ko
}

KERNEL_MODULE_AUTOLOAD += "rswlan"
KERNEL_MODULE_PROBECONF += "rswlan"
