FILESEXTRAPATHS_prepend := "${THISDIR}/files/common:${THISDIR}/files/${MACHINE}:${THISDIR}/files:"

DEPENDS_append_dh-imx6-dhsom = "u-boot-mkimage-native"
do_compile_append_dh-imx6-dhsom () {
	uboot-mkimage -A arm -T script -C none \
		-d ${WORKDIR}/boot.cmd ${WORKDIR}/boot.scr
}

SRC_URI_append_dh-imx6-dhsom = " \
	file://boot.cmd \
	file://fw_env.config \
	file://0001-ARM-imx-Revert-dh_imx6-Switch-to-full-DM-aware.patch \
	file://0002-ARM-imx6-dh-imx6-Move-bootcounter-to-SNVS_LPGDR.patch \
	file://0003-ARM-imx6-dh-imx6-Enable-support-for-applying-DTO.patch \
	file://0004-ARM-imx6-dh-imx6-Add-update_sf-script-to-install-U-B.patch \
	"
