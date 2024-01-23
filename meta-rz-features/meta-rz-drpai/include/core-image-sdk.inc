sdk_post_process () {
# Modify ls.so.conf for multilib environment
# only support aarch64 and armv7xxx case
if [ "${MULTILIBS}" != "" ]; then
    echo "Setup /etc/ld.so.conf for the SDK with multilib environment"

    . $target_sdk_dir/environment-setup-@REAL_MULTIMACH_TARGET_SYS@
    $SUDO_EXEC sed -i "1i /usr/lib64" ${OECORE_TARGET_SYSROOT}/etc/ld.so.conf
    $SUDO_EXEC sed -i "1i /lib64" ${OECORE_TARGET_SYSROOT}/etc/ld.so.conf
fi
}

SDK_POST_INSTALL_COMMAND_append = " ${sdk_post_process}"

