#
# This recipe adds a header file of DRP-AI driver to RZ/V2L SDK environment.
#

DESCRIPTION = "Recipe for header file of DRP-AI driver"
SECTION = "libs"
DEPENDS = ""
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${MACHINE_ARCH}"
PACKAGES = "${PN}"
PROVIDES = "${PN}"

PR = "r1"

SRC_URI = "file://drpai.h"

# The list of directories or files that are placed in packages.
FILES_${PN} = " \
    ${includedir}/linux/drpai.h \
    "

S = "${WORKDIR}"

do_install() {
    install -d ${D}/${includedir}/linux
    install -m 0755 ${S}/drpai.h ${D}/${includedir}/linux
}
