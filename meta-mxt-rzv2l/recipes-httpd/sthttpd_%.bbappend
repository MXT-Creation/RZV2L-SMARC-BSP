
# clear out any files; we're installing our own
do_install_append () {
    rm -rf ${D}${SRV_DIR}/*
}

