FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}/${MACHINE}:${THISDIR}/${PN}:${THISDIR}/files/${MACHINE}:${THISDIR}/files:"

SRC_URI:append:dh-imx-dhsom = " \
	file://boot.cmd \
	file://fw_env.config \
	"
