FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append:dh-imx8mp-dhsom = " \
	file://0001-drm-bridge-tc358767-Change-tc_-prefix-to-tc_edp_-for.patch \
	file://0002-drm-bridge-tc358767-Convert-to-atomic-ops.patch \
	file://0003-drm-bridge-tc358767-Implement-atomic_check-callback.patch \
	file://0004-drm-bridge-tc358767-Move-e-DP-bridge-endpoint-parsin.patch \
	file://0005-drm-bridge-tc358767-Wrap-e-DP-aux-I2C-registration-i.patch \
	file://0006-drm-bridge-tc358767-Move-bridge-ops-setup-into-tc_pr.patch \
	file://0007-drm-bridge-tc358767-Detect-bridge-mode-from-connecte.patch \
	file://0008-drm-bridge-tc358767-Split-tc_set_video_mode-into-com.patch \
	file://0009-drm-bridge-tc358767-Add-DSI-to-DPI-mode-support.patch \
	file://0010-drm-bridge-tc358767-Fix-e-DP-bridge-endpoint-parsing.patch \
	file://0011-drm-bridge-tc358767-Fix-DP-bridge-mode-detection-fro.patch \
	file://0012-drm-bridge-tc358767-Factor-out-DSI-and-DPI-RX-enable.patch \
	file://0013-drm-bridge-tc358767-Add-DSI-to-e-DP-mode-support.patch \
	file://0014-drm-bridge-tc358767-Handle-dsi_lanes-0-as-invalid.patch \
	file://0015-drm-bridge-tc358767-Report-DSI-to-e-DP-as-supported.patch \
	file://0016-drm-bridge-tc358767-Make-sure-Refclk-clock-are-enabl.patch \
	file://0017-drm-bridge-tc358767-Attach-bridge-in-bridge-attach-c.patch \
	file://0018-clk-imx8mp-add-clkout1-2-support.patch \
	file://0019-clk-imx-pll14xx-Use-register-defines-consistently.patch \
	file://0020-clk-imx-pll14xx-Drop-wrong-shifting.patch \
	file://0021-clk-imx-pll14xx-Use-FIELD_GET-FIELD_PREP.patch \
	file://0022-clk-imx-pll14xx-consolidate-rate-calculation.patch \
	file://0023-clk-imx-pll14xx-name-variables-after-usage.patch \
	file://0024-clk-imx-pll14xx-explicitly-return-lowest-rate.patch \
	file://0025-clk-imx-pll14xx-Add-pr_fmt.patch \
	file://0026-clk-imx-pll14xx-Support-dynamic-rates.patch \
	file://0027-clk-imx-pll14xx-Add-320-MHz-and-640-MHz-entries-for-.patch \
	file://0028-gpio-mxc-Protect-GPIO-irqchip-RMW-with-bgpio-spinloc.patch \
	file://0029-gpio-mxc-Always-set-GPIOs-used-as-interrupt-source-t.patch \
	file://0030-gpio-mxc-Always-set-GPIOs-requested-as-interrupt-sou.patch \
	file://0031-Bluetooth-btbcm-Add-entry-for-BCM4373A0-UART-Bluetoo.patch \
	file://0032-Bluetooth-hci_bcm-Add-CYW4373A0-support.patch \
	file://0033-iio-ti-ads1015-Remove-shift-variable-ads1015_read_ra.patch \
	file://0034-iio-adc-ti-ads1015-Suppress-clang-W-1-warning-about-.patch \
	file://0035-iio-adc-ti-ads1015-Switch-to-static-const-writeable-.patch \
	file://0036-iio-adc-ti-ads1015-Deduplicate-channel-macros.patch \
	file://0037-iio-adc-ti-ads1015-Make-channel-event_spec-optional.patch \
	file://0038-iio-adc-ti-ads1015-Add-TLA2024-support.patch \
	file://0039-iio-adc-ti-ads1015-Add-static-assert-to-test-if-shif.patch \
	file://0040-iio-adc-ti-ads1015-Convert-to-OF-match-data.patch \
	file://0041-iio-adc-ti-ads1015-Replace-data_rate-with-chip-data-.patch \
	file://0042-iio-adc-ti-ads1015-Switch-to-read_avail.patch \
	file://0043-usb-dwc3-imx8mp-rename-iomem-base-pointer.patch \
	file://0044-usb-dwc3-imx8mp-Add-support-for-setting-SOC-specific.patch \
	file://0045-dt-bindings-arm-Add-DH-electronics-i.MX8M-Plus-DHCOM.patch \
	file://0046-arm64-dts-imx8mp-Add-memory-for-USB3-glue-layer-to-u.patch \
	file://0047-arm64-dts-imx8mp-Add-support-for-DH-electronics-i.MX.patch \
	file://0048-arm64-dts-imx8mp-Add-HW-variant-details-to-i.MX8M-Pl.patch \
	file://0049-arm64-dts-imx8mp-Drop-Atheros-PHY-header-from-i.MX8M.patch \
	file://0050-arm64-dts-imx8mp-Add-SoM-compatible-to-i.MX8M-Plus-D.patch \
	file://0051-arm64-dts-imx8mp-Add-PCIe-support-to-DH-electronics-.patch \
	file://0052-arm64-dts-imx8mp-Enable-HDMI-on-MX8MP-DHCOM-PDK2.patch \
	file://0053-arm64-dts-imx8mp-Enable-weak-pullup-until-R269-is-po.patch \
	file://0054-arm64-dts-imx8mp-Add-SGTL5000-codec-on-MX8MP-DHCOM-P.patch \
	file://0055-arm64-dts-imx8mp-Add-TC9595-bridge-on-MX8MP-DHCOM-So.patch \
	file://0056-arm64-dts-imx8mp-Adjust-ECSPI1-pinmux-on-i.MX8M-Plus.patch \
	file://0057-arm64-dts-imx8mp-Fix-I2C5-GPIO-assignment-on-i.MX8M-.patch \
	file://0058-arm64-dts-imx8mp-Bind-bluetooth-UART-on-DH-electroni.patch \
	file://0059-arm64-dts-imx8mp-Add-DT-overlays-for-i.MX8MP-DHCOM-P.patch \
	file://0060-arm64-dts-imx8mp-Adjust-DT-to-match-downstream-DTSI.patch \
	"

# Inject extra config options into kernel config this way,
# since various recipes in meta-imx patch the imx_v8_defconfig
# and we have no way of knowing what it would look like here.
do_copy_defconfig:append:dh-imx8mp-dhsom () {
    echo "CONFIG_BT=y" >> ${B}/.config
    echo "# CONFIG_BT_HCIBTSDIO is not set" >> ${B}/.config
    echo "CONFIG_BT_RFCOMM=y" >> ${B}/.config
    echo "CONFIG_BT_RFCOMM_TTY=y" >> ${B}/.config
    echo "CONFIG_BT_BNEP=y" >> ${B}/.config
    echo "CONFIG_BT_BNEP_MC_FILTER=y" >> ${B}/.config
    echo "CONFIG_BT_BNEP_PROTO_FILTER=y" >> ${B}/.config
    echo "CONFIG_BT_HIDP=y" >> ${B}/.config
    echo "CONFIG_BT_HS=y" >> ${B}/.config
    echo "CONFIG_BT_LE=y" >> ${B}/.config
    echo "CONFIG_BT_LEDS=y" >> ${B}/.config
    echo "CONFIG_BT_MSFTEXT=y" >> ${B}/.config
    echo "CONFIG_BT_AOSPEXT=y" >> ${B}/.config
    echo "CONFIG_BT_DEBUGFS=y" >> ${B}/.config
    echo "CONFIG_BT_HCIUART=m" >> ${B}/.config
    echo "CONFIG_BT_HCIUART_3WIRE=y" >> ${B}/.config
    echo "CONFIG_BT_HCIUART_BCM=y" >> ${B}/.config
    echo "CONFIG_BT_HCIUART_H4=y" >> ${B}/.config
    echo "CONFIG_BRCMFMAC=m" >> ${B}/.config
    echo "CONFIG_DRM_TOSHIBA_TC358767=y" >> ${B}/.config
}
