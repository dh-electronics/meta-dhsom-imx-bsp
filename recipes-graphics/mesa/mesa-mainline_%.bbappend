FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
# MESA_BUILD_TYPE = "debug"
PACKAGECONFIG:append:dh-imx-dhsom = " \
	etnaviv kmsro gallium \
	${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'wayland', '', d)} \
	"
