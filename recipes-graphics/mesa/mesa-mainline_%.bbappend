FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
# MESA_BUILD_TYPE = "debug"
DEFAULT_PREFERRENCE_dh-imx6-dhsom = "1"
PACKAGECONFIG_append_dh-imx6-dhsom = " \
	etnaviv kmsro gallium \
	${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'wayland', '', d)} \
	"
