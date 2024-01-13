FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}/${MACHINE}:${THISDIR}/${PN}:${THISDIR}/files/${MACHINE}:${THISDIR}/files:"

require u-boot-dhsom-common.inc

SRC_URI:append:dh-imx-dhsom = " \
	file://default-device-tree.cfg \
	file://0001-ARM-imx-Drop-CONFIG_USE_BOOTCOMMAND-n-on-i.MX6-DHSOM.patch \
	file://0002-ARM-imx-Use-default-SAVED_DRAM_TIMING_BASE-on-DH-i.M.patch \
	file://0003-spl-fit-Add-board-level-function-to-decide-applicati.patch \
	file://0004-arm64-dts-imx8mp-Switch-to-DT-overlays-for-i.MX8MP-D.patch \
	file://0005-arm64-dts-imx8mp-Update-i.MX8MP-DHCOM-SoM-DT-to-prod.patch \
	file://0006-arm64-dts-imx8mp-Drop-i.MX8MP-DHCOM-rev.100-PHY-addr.patch \
	file://0007-arm64-dts-imx8mp-Add-DT-overlay-describing-i.MX8MP-D.patch \
	file://0008-ARM-imx-Enable-CAAM-on-DH-i.MX8M-Plus-DHCOM.patch \
	file://0009-ddr-imx-Add-3600-MTps-rate-support.patch \
	file://0010-ARM-imx-Force-DRAM-regulators-into-FPWM-mode-on-DH-i.patch \
	file://0011-ARM-imx-Update-DRAM-timings-with-inline-ECC-on-DH-i..patch \
	file://0012-imx-spl_imx_romapi-avoid-tricky-use-of-spl_load_simp.patch \
	file://0013-imx-spl_imx_romapi-fix-emmc-fast-boot-mode-case.patch \
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
UBOOT_LOCALVERSION:dh-imx-dhsom ?= "-${MACHINE}-20240113.01"
