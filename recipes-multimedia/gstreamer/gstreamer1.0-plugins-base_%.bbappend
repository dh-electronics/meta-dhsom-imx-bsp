PACKAGECONFIG:append:dh-imx-dhsom = " \
	gbm egl \
	${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'wayland', '', d)} \
	"
