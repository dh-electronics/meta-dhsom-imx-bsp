MACHINEOVERRIDES =. "dh-imx8m-dhsom:dh-imx8mp-dhsom:"

# Include downstream BSP extras only if enabled by setting
# IMX_DEFAULT_BSP = "nxp" in local.conf
include conf/machine/include/dh-imx${@'8mp-downstream' if (d.getVar('IMX_DEFAULT_BSP') in ["nxp"]) else '-mainline'}.inc
require conf/machine/include/dh-imx-common.inc

DEFAULTTUNE ?= "cortexa53-crypto"
SOC_FAMILY ?= "imx8mp"

require conf/machine/include/${@'' if (d.getVar('LAYERSERIES_CORENAMES') in ["dunfell"]) else 'arm/armv8a/'}tune-cortexa53.inc
require conf/machine/include/soc-family.inc

SERIAL_CONSOLE = "115200 ttymxc0"

# Linux kernel
PREFERRED_VERSION_linux-stable ?= "6.6%"
KERNEL_DTBVENDORED = "1"
KERNEL_DTC_FLAGS += "-@"

# U-Boot bootloader
UBOOT_ENTRYPOINT := "0x40200000"
UBOOT_MAKE_TARGET := "flash.bin"
UBOOT_BINARY := "flash.bin"
UBOOT_SUFFIX ?= "bin"
UBOOT_DTB_LOADADDRESS = "0x5c000000"
UBOOT_DTBO_LOADADDRESS = "0x5c080000"

WKS_FILE = "sdimage-imx8mp.wks"

# Add any optional config files that might be present e.g. in other layers
include conf/machine/include/dh-imx8mp-common-extra.inc
include conf/machine/${MACHINE}-extra.conf
