PACKAGECONFIG_append_dh-imx6-dhsom = " \
	kms \
	${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'wayland', '', d)} \
	"
