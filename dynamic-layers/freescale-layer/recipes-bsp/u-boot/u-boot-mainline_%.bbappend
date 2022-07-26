do_compile[depends] += "${@'firmware-imx-8m:do_deploy imx-atf:do_deploy' if (('dh-imx8mp-dhsom' in d.getVar('MACHINEOVERRIDES', True).split(':')) and (d.getVar('IMX_DEFAULT_BSP') in ["nxp"])) else ' '}"

do_deploy:append:use-nxp-bsp() {
    install -d ${DEPLOYDIR}/imx-boot-tools
    install -m 0644 ${B}/arch/arm/dts/${UBOOT_DTB_NAME} ${DEPLOYDIR}/imx-boot-tools/${UBOOT_DTB_NAME}
    install -m 0644 ${B}/u-boot-nodtb.bin ${DEPLOYDIR}/imx-boot-tools/u-boot-nodtb.bin-${MACHINE}-${UBOOT_CONFIG}
    install -m 0644 ${B}/u-boot.bin ${DEPLOYDIR}/u-boot-${MACHINE}.bin-${UBOOT_CONFIG}
    install -m 0644 ${B}/spl/u-boot-spl.bin ${DEPLOYDIR}/u-boot-spl.bin-${MACHINE}-${UBOOT_CONFIG}
}
