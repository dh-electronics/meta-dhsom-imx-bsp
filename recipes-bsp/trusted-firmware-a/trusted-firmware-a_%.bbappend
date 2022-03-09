COMPATIBLE_MACHINE:dh-imx8mp-dhsom = "dh-imx8mp-dhsom"
TFA_PLATFORM:dh-imx8mp-dhsom = "imx8mp"
TFA_BUILD_TARGET:dh-imx8mp-dhsom = "bl31"

do_compile:prepend:dh-imx8mp-dhsom() {
	sed -i "/BL31_BASE/  s@0x960000@0x970000@" ${S}/plat/imx/imx8m/imx8mp/include/platform_def.h
	sed -i "/BL31_LIMIT/ s@0x980000@0x990000@" ${S}/plat/imx/imx8m/imx8mp/include/platform_def.h
}

EXTRA_OEMAKE:append:dh-imx8mp-dhsom = " IMX_BOOT_UART_BASE=0x30860000 "
