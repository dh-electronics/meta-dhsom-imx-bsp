FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:${THISDIR}/files/common:${THISDIR}/files/${MACHINE}:${THISDIR}/files:"

DEPENDS:append:dh-imx-dhsom = " u-boot-mainline-tools-native "
do_compile:append:dh-imx-dhsom () {
	sed -i -e "s/%UBOOT_DTB_LOADADDRESS%/${UBOOT_DTB_LOADADDRESS}/g" \
		-e "s/%UBOOT_DTBO_LOADADDRESS%/${UBOOT_DTBO_LOADADDRESS}/g" \
		${WORKDIR}/boot.cmd
	uboot-mkimage -A arm -T script -C none \
		-d ${WORKDIR}/boot.cmd ${WORKDIR}/boot.scr
}

SRC_URI:append:dh-imx-dhsom = " \
	file://0001-gpio-fix-incorrect-depends-on-for-SPL_GPIO_HOG.patch \
	file://0002-Revert-i2c-fix-stack-buffer-overflow-vulnerability-i.patch \
	file://0003-i2c-fix-stack-buffer-overflow-vulnerability-in-i2c-m.patch \
	file://0004-mmc-fsl_esdhc-fix-problem-when-using-clk-driver.patch \
	"

SRC_URI:append:dh-imx6-dhsom = " \
	file://0001-ARM-imx-dh-imx6-Increase-SF-erase-area-for-u-boot-up.patch \
	file://boot.cmd \
	file://fw_env.config \
	"

# U-Boot release extra version, used as identifier of a patch
# release. Update this every time this recipe is updated. The
# format is -${MACHINE}-date.extraversion. The date is in the
# format YYYYMMDD, the extraversion is used in case there are
# multiple releases during a single day, which is unlikely.
UBOOT_LOCALVERSION:dh-stm32mp1-dhsom ?= "-${MACHINE}-20220924.01"
