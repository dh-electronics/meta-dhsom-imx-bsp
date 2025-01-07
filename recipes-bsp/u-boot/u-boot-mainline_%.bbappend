FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}/${MACHINE}:${THISDIR}/${PN}:${THISDIR}/files/${MACHINE}:${THISDIR}/files:"

require u-boot-dhsom-common.inc

SRC_URI:append:dh-imx-dhsom = " \
	file://default-device-tree.cfg \
	file://0001-scripts-setlocalversion-Reinstate-.scmversion-suppor.patch \
	file://0002-env-Switch-the-callback-static-list-to-Kconfig.patch \
	file://0003-arm64-dts-imx8mp-Add-aliases-for-the-access-to-the-E.patch \
	file://0004-arm64-imx8mp-Read-values-from-M24C32-D-write-lockabl.patch \
	file://0005-lib-hashtable-Prevent-recursive-calling-of-callback-.patch \
	file://0006-board-dhelectronics-Sync-env-variable-dh_som_serial_.patch \
	file://0007-mmc-Fix-size-calculation-for-sector-addressed-MMC-ve.patch \
	file://0008-ARM-dts-imx-Drop-bogus-regulator-extras-on-DH-i.MX6-.patch \
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
UBOOT_LOCALVERSION:dh-imx-dhsom ?= "-${MACHINE}-20250311.01"
