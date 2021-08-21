PACKAGECONFIG:append:dh-imx6-dhsom = " \
	gbm egl \
	${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'wayland', '', d)} \
	"
