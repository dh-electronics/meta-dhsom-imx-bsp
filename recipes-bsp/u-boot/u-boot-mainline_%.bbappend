FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}/${MACHINE}:${THISDIR}/${PN}:${THISDIR}/files/${MACHINE}:${THISDIR}/files:"

require u-boot-dhsom-common.inc

SRC_URI:append:dh-imx-dhsom = " \
	file://default-device-tree.cfg \
	file://0001-ARM-imx-Enable-SPL-DTO-application-support-for-i.MX8.patch \
	file://0002-arm-imx-Enable-always-on-regulators-using-board-spec.patch \
	file://0003-ARM-imx-Enable-PCA953x-driver-on-DH-i.MX8MP-DHCOM-PD.patch \
	file://0004-ARM-imx-Update-Fast-ethernet-PHY-MDIO-addresses-to-m.patch \
	file://0005-arm64-dts-imx8mp-Add-DH-i.MX8MP-DHCOM-SoM-on-DRC02-c.patch \
	file://0006-arm64-dts-imx8mp-Add-support-for-DH-electronics-i.MX.patch \
	"

EXTRA_OEMAKE:append:dh-imx8mp-dhsom = " ATF_LOAD_ADDR=0x970000"

do_compile[depends] += "${@'imx-firmware:do_deploy trusted-firmware-a:do_deploy' if ('dh-imx8mp-dhsom' in d.getVar('MACHINEOVERRIDES', True).split(':')) else ' '}"

do_compile:prepend:dh-imx8mp-dhsom () {
	cp -Lv ${DEPLOY_DIR_IMAGE}/lpddr4_pmu_train_*mem*202006.bin ${B}/
	cp -Lv ${DEPLOY_DIR_IMAGE}/bl31-imx8mp.bin ${B}/bl31.bin
}

# U-Boot release extra version, used as identifier of a patch
# release. Update this every time this recipe is updated. The
# format is -${MACHINE}-date.extraversion. The date is in the
# format YYYYMMDD, the extraversion is used in case there are
# multiple releases during a single day, which is unlikely.
UBOOT_LOCALVERSION:dh-imx-dhsom ?= "-${MACHINE}-20241003.02"
