def check_debian_mode(d):
  debian = d.getVar("CIP_MODE")
  if debian == 'Buster' or debian == 'Bullseye':
     return 'debian'
  else:
     d.setVar("CIP_MODE", "None")
     return 'nondebian'

DEBIAN_BASED = "${@check_debian_mode(d)}"
OVERRIDES .= ":${DEBIAN_BASED}"

BBMASK_append_nondebian = " recipes-debian"

BBMASK_append_debian = " perl_debian"

# Select gcc,gdb, python3 debian version
GCCVERSION_debian = "8.3.0"
SDKGCCVERSION_debian = "${GCCVERSION}"

GLIBCVERSION_debian = "${@'2.28%' if 'Buster' in '${CIP_MODE}' else '2.31%'}"
PREFERRED_VERSION_glibc_debian = "${GLIBCVERSION}"
PREFERRED_VERSION_nativesdk-glibc_debian = "${GLIBCVERSION}"
PREFERRED_VERSION_nativesdk-glibc-locale_debian = "${GLIBCVERSION}"

BINUVERSION_debian = "2.31.%"
PREFERRED_VERSION_nativesdk-binutils_debian = "${BINUVERSION}"

PREFERRED_VERSION_gdb_debian = "8.1"

PREFERRED_VERSION_busybox_debian = "1.30.%"

RDEPENDS_xz_append_debian = "bash"
RDEPENDS_gzip_append_debian = "bash"
RDEPENDS_adduser_append_debian = "perl"

# Using the package versions provided in the security update mirror
# is now necessary to pull updates by Debian LTS
DEBIAN_SECURITY_UPDATE_MIRROR ?= "https://security.debian.org/debian-security/pool/updates"
