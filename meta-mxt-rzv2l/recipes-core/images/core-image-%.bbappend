IMAGE_FEATURES_remove = " ssh-server-dropbear"
IMAGE_FEATURES_append = " ssh-server-openssh"

IMAGE_INSTALL_append = " \
	u-boot-tools \
	custom-configs \
	kernel-image \
	kernel-devicetree \
	htop \
	iperf3 \
	da16600 \
	app-usbcam-http \
	app-usbcam-client \
"

