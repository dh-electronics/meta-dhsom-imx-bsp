FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
# MESA_BUILD_TYPE = "debug"
PACKAGECONFIG:append:dh-imx-dhsom = " \
	etnaviv kmsro gallium \
	${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'wayland', '', d)} \
	"

EXTRA_OEMESON:append:dh-imx8mp-dhsom = " ${@'' if d.getVar('LAYERSERIES_CORENAMES') in ["kirkstone"] else '-Dteflon=true'}"
FILES:mesa-megadriver:append:dh-imx8mp-dhsom = " ${libdir}/libteflon.so"
