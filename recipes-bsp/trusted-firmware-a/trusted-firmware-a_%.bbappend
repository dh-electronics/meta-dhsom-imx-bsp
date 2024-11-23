FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
COMPATIBLE_MACHINE:dh-imx8mp-dhsom = "dh-imx8mp-dhsom"
TFA_PLATFORM:dh-imx8mp-dhsom = "imx8mp"
TFA_BUILD_TARGET:dh-imx8mp-dhsom = "bl31"

EXTRA_OEMAKE:append:dh-imx8mp-dhsom = " IMX_BOOT_UART_BASE=0x30860000 "
