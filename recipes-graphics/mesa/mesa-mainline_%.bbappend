FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
# MESA_BUILD_TYPE = "debug"
PACKAGECONFIG:append:dh-imx-dhsom = " \
	etnaviv gallium \
	${@'kmsro' if (bb.utils.vercmp_string_op(d.getVar('PV'), '25.0.0', '<')) else ''} \
	${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'wayland', '', d)} \
	"

EXTRA_OEMESON:append:dh-imx8mp-dhsom = " -Dteflon=true"
FILES:mesa-megadriver:append:dh-imx8mp-dhsom = " ${libdir}/libteflon.so"
