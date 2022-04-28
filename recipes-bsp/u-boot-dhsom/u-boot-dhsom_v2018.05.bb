require u-boot-dhsom-common_v2018.05.inc
require recipes-bsp/u-boot/u-boot-mainline.inc

DEPENDS += "bc-native dtc-native"

PROVIDES += "u-boot"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}/common:${THISDIR}/${PN}/${MACHINE}:${THISDIR}/${PN}:"
RPROVIDES:${PN} = "virtual/bootloader"

DEPENDS:append:dh-imx-dhsom = " u-boot-dhsom-tools-native "
do_compile:append:dh-imx-dhsom () {
	sed -i -e "s/%UBOOT_DTB_LOADADDRESS%/${UBOOT_DTB_LOADADDRESS}/g" \
		-e "s/%UBOOT_DTBO_LOADADDRESS%/${UBOOT_DTBO_LOADADDRESS}/g" \
		${WORKDIR}/boot.cmd
	uboot-mkimage -A arm -T script -C none \
		-d ${WORKDIR}/boot.cmd ${WORKDIR}/boot.scr
}

SRC_URI:append:dh-imx6-dhsom = " \
	file://boot.cmd \
	"


