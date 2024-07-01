FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}/${MACHINE}:${THISDIR}/${PN}:${THISDIR}/files/${MACHINE}:${THISDIR}/files:"

require u-boot-dhsom-common.inc

SRC_URI:append:dh-imx-dhsom = " \
	file://default-device-tree.cfg \
	file://0001-ARM-imx-Set-stdio-to-serial-on-DH-i.MX8M-Plus-DHCOM.patch \
	file://0002-ARM-imx-Enable-SPL_BOARD_INIT-on-DH-i.MX8M-Plus-DHCO.patch \
	file://0003-ARM-imx-Enable-kaslrseed-command-on-DH-i.MX8M-Plus-D.patch \
	file://0004-ARM-imx-Enable-SPL-DTO-application-support-for-i.MX8.patch \
	file://0005-power-regulator-Trigger-probe-of-regulators-which-ar.patch \
	file://0006-power-regulator-Convert-regulators_enable_boot_on-of.patch \
	file://0007-power-regulator-Drop-regulator_unset.patch \
	file://0008-power-regulator-Drop-regulators_enable_boot_on-off.patch \
	file://0009-ARM-imx-Enable-PCA953x-driver-on-DH-i.MX8MP-DHCOM-PD.patch \
	file://0010-ARM-imx-Update-Fast-ethernet-PHY-MDIO-addresses-to-m.patch \
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
UBOOT_LOCALVERSION:dh-imx-dhsom ?= "-${MACHINE}-20240701.01"
