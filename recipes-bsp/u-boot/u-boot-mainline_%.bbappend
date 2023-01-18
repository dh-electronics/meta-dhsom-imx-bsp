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
	file://boot.cmd \
	file://fw_env.config \
	file://0001-u-boot-initial-env-rework-make-target.patch \
	"

SRC_URI:append:dh-imx8mp-dhsom = " \
	file://0001-ARM-imx-bootaux-Fix-macro-misuse.patch \
	file://0002-ARM-imx-bootaux-Fix-LTO-Wlto-type-mismatch.patch \
	file://0003-ARM-imx-Enable-LTO-for-DH-electronics-i.MX8M-Plus-DH.patch \
	file://0004-ARM-imx-Add-2-GiB-DRAM-support-for-DH-electronics-i..patch \
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
UBOOT_LOCALVERSION:dh-imx-dhsom ?= "-${MACHINE}-20230218.02"
