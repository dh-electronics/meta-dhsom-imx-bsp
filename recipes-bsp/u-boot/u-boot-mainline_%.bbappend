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

SRC_URI:append:dh-imx6-dhsom = " \
	file://0001-ARM-dts-imx-Add-WDT-bindings-on-DH-i.MX6-DHSOM.patch \
	"

SRC_URI:append:dh-imx8mp-dhsom = " \
	file://0001-ARM-imx-bootaux-Fix-macro-misuse.patch \
	file://0002-ARM-imx-bootaux-Fix-LTO-Wlto-type-mismatch.patch \
	file://0003-ARM-imx-Enable-LTO-for-DH-electronics-i.MX8M-Plus-DH.patch \
	file://0004-ARM-imx-Add-2-GiB-DRAM-support-for-DH-electronics-i..patch \
	file://0005-arm64-imx8mp-Disable-Atheros-PHY-driver.patch \
	file://0006-arm64-imx8mp-Enable-SMSC-LAN87xx-PHY-driver.patch \
	file://0007-clk-imx8mp-Add-EQoS-MAC-clock.patch \
	file://0008-net-Pull-board_interface_eth_init-into-common-code.patch \
	file://0009-net-dwc_eth_qos-Drop-bogus-return-after-goto.patch \
	file://0010-net-dwc_eth_qos-Drop-unused-dm_gpio_free-on-STM32.patch \
	file://0011-net-dwc_eth_qos-Staticize-eqos_inval_buffer_tegra186.patch \
	file://0012-net-dwc_eth_qos-Set-DMA_MODE-SWR-bit-to-reset-the-MA.patch \
	file://0013-net-dwc_eth_qos-Add-DM-CLK-support-for-i.MX8M-Plus.patch \
	file://0014-net-dwc_eth_qos-Add-i.MX8M-Plus-RMII-support.patch \
	file://0015-net-dwc_eth_qos-Add-board_interface_eth_init-for-i.M.patch \
	file://0016-net-fec_mxc-Add-ref-clock-setup-support-for-i.MX8M-M.patch \
	file://0017-net-fec_mxc-Add-board_interface_eth_init-for-i.MX8M-.patch \
	file://0018-arm64-dts-imx8mp-Drop-EQoS-clock-workaround.patch \
	file://0019-arm64-imx8mp-Drop-EQoS-GPR-1-board-workaround.patch \
	file://0020-arm64-imx8mm-imx8mn-imx8mp-Drop-FEC-GPR-1-board-work.patch \
	file://0021-arm64-dts-imx8mp-Adjust-EQoS-PHY-address-on-i.MX8MP-.patch \
	file://0022-arm64-dts-imx8mp-Add-EQoS-RMII-pin-mux-on-i.MX8MP-DH.patch \
	file://0023-arm64-dts-imx8mp-Add-FEC-RMII-pin-mux-on-i.MX8MP-DHC.patch \
	file://0024-arm64-dts-imx8mp-Do-not-delete-PHY-nodes-on-i.MX8MP-.patch \
	file://0025-arm64-imx8mp-Auto-detect-PHY-on-i.MX8MP-DHCOM.patch \
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
UBOOT_LOCALVERSION:dh-imx-dhsom ?= "-${MACHINE}-20230306.01"
