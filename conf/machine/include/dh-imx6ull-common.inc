MACHINEOVERRIDES =. "dh-imx6ull-dhsom:"

require conf/machine/include/dh-imx-mainline.inc
require conf/machine/include/dh-imx-common.inc

DEFAULTTUNE ?= "cortexa7thf-neon-vfpv4"
SOC_FAMILY ?= "imx6ull"

# U-Boot bootloader
UBOOT_ENTRYPOINT := "0x80008000"
UBOOT_DTB_LOADADDRESS = "0x87f00000"
UBOOT_DTBO_LOADADDRESS = "0x87f80000"

PREFERRED_PROVIDER_virtual/bootloader := "u-boot-dhsom"
PREFERRED_PROVIDER_u-boot := "u-boot-dhsom"
PREFERRED_VERSION_u-boot-dhsom := "2018.05%"

DH_UBOOT_RECIPE = "u-boot-dhsom"
require conf/machine/include/${@'' if (d.getVar('LAYERSERIES_CORENAMES') in ["dunfell"]) else 'arm/armv7a/'}tune-cortexa7.inc
require conf/machine/include/dh-imx6-common.inc

# Linux kernel
PREFERRED_VERSION_linux-stable := "6.1%"
