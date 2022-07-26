COMPATIBLE_MACHINE:dh-imx8mp-dhsom = "dh-imx8mp-dhsom"
ATF_PLATFORM:dh-imx8mp-dhsom = "imx8mp"
EXTRA_OEMAKE:append:dh-imx8mp-dhsom = " IMX_BOOT_UART_BASE=0x30860000"

do_deploy:append() {
    install -d ${DEPLOYDIR}/imx-boot-tools
    install -m 0644 ${S}/build/${ATF_PLATFORM}/release/bl31.bin ${DEPLOYDIR}/bl31-${ATF_PLATFORM}.bin
}
