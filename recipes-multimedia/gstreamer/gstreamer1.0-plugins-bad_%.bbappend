PACKAGECONFIG:append:dh-imx-dhsom = " \
	kms \
	${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'wayland', '', d)} \
	"
