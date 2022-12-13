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
	file://boot.cmd \
	file://fw_env.config \
	"

SRC_URI:append:dh-imx6-dhsom = " \
	file://0001-ARM-imx-dh-imx6-Increase-SF-erase-area-for-u-boot-up.patch \
	"

SRC_URI:append:dh-imx8mp-dhsom = " \
	file://0001-ARM-imx-Enable-USB-ethernet-on-i.MX8M-Plus-DHCOM.patch \
	file://0002-ARM-dts-imx-Add-HW-variant-details-to-i.MX8M-Plus-DH.patch \
	file://0003-ARM-dts-imx-Drop-Atheros-PHY-header-from-i.MX8M-Plus.patch \
	file://0004-ARM-dts-imx-Add-SoM-compatible-to-i.MX8M-Plus-DHCOM-.patch \
	file://0005-ARM-dts-imx-Rename-imx8mp-dhcom-pdk2-boot.dtsi.patch \
	file://0006-ARM-dts-imx-Adjust-ECSPI1-pinmux-on-i.MX8M-Plus-DHCO.patch \
	file://0007-ARM-dts-imx-Fix-I2C5-GPIO-assignment-on-i.MX8M-Plus-.patch \
	file://0008-imx8mp-synchronise-device-tree-with-linux.patch \
	file://0009-imx8mp-synchronise-device-tree-with-linux.patch \
	"

EXTRA_OEMAKE:append:dh-imx8mp-dhsom = " ATF_LOAD_ADDR=0x970000"

do_compile[depends] += "${@'imx-firmware:do_deploy trusted-firmware-a:do_deploy' if (('dh-imx8mp-dhsom' in d.getVar('MACHINEOVERRIDES', True).split(':')) and not (d.getVar('IMX_DEFAULT_BSP') in ["nxp"])) else ' '}"

do_compile:prepend:dh-imx8mp-dhsom () {
	cp -Lv ${DEPLOY_DIR_IMAGE}/lpddr4_pmu_train_*mem*202006.bin ${B}/
	cp -Lv ${DEPLOY_DIR_IMAGE}/bl31-imx8mp.bin ${B}/bl31.bin
}

# U-Boot release extra version, used as identifier of a patch
# release. Update this every time this recipe is updated. The
# format is -${MACHINE}-date.extraversion. The date is in the
# format YYYYMMDD, the extraversion is used in case there are
# multiple releases during a single day, which is unlikely.
UBOOT_LOCALVERSION:dh-stm32mp1-dhsom ?= "-${MACHINE}-20221014.01"
