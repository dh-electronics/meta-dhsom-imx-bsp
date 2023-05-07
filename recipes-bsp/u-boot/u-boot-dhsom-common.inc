require recipes-bsp/u-boot/u-boot-mainline.inc

DEPENDS += "bc-native dtc-native"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}/${MACHINE}:${THISDIR}/${PN}:${THISDIR}/files/${MACHINE}:${THISDIR}/files:"

DEPENDS:append:dh-imx-dhsom = " u-boot-mainline-tools-native "
do_compile:append:dh-imx-dhsom () {
	sed -i -e "s/%UBOOT_DTB_LOADADDRESS%/${UBOOT_DTB_LOADADDRESS}/g" \
		-e "s/%UBOOT_DTBO_LOADADDRESS%/${UBOOT_DTBO_LOADADDRESS}/g" \
		${WORKDIR}/boot.cmd
	uboot-mkimage -A arm -T script -C none \
		-d ${WORKDIR}/boot.cmd ${WORKDIR}/boot.scr
}

SRC_URI:append:dh-imx6-dhsom = " \
	file://boot.cmd \
	file://fw_env.config \
	"
