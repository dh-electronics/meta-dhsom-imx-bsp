FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
# MESA_BUILD_TYPE = "debug"
DEFAULT_PREFERENCE:dh-imx6-dhsom = "1"
PACKAGECONFIG:append:dh-imx6-dhsom = " \
	etnaviv kmsro gallium \
	${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'wayland', '', d)} \
	"
