PACKAGECONFIG:append:dh-imx-dhsom = " \
	kms v4l2codecs \
	${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'wayland', '', d)} \
	"
