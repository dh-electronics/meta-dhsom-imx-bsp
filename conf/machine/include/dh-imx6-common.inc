MACHINEOVERRIDES =. "dh-imx6-dhsom:"

require conf/machine/include/dh-imx-common.inc

DEFAULTTUNE ?= "cortexa9thf-neon"
SOC_FAMILY ?= "imx6"

ARM_INSTRUCTION_SET = "thumb"

require conf/machine/include/${@'' if (d.getVar('LAYERSERIES_CORENAMES') in ["dunfell"]) else 'arm/armv7a/'}tune-cortexa9.inc
require conf/machine/include/soc-family.inc

SERIAL_CONSOLE = "115200 ttymxc0"

# Linux kernel
PREFERRED_VERSION_linux-stable ?= "5.10%"

# U-Boot bootloader
UBOOT_ENTRYPOINT := "0x17800000"
UBOOT_MAKE_TARGET := "u-boot-with-spl.imx"
UBOOT_BINARY := "u-boot-with-spl.imx"
UBOOT_SUFFIX ?= "imx"
UBOOT_DTB_LOADADDRESS = "0x1ff00000"
UBOOT_DTBO_LOADADDRESS = "0x1ff80000"

# Ship kernel modules
MACHINE_ESSENTIAL_EXTRA_RDEPENDS += " \
	imx-firmware-sdma-imx6q \
	imx-firmware-vpu-imx6d \
	imx-firmware-vpu-imx6q \
	"

WKS_FILE ?= "sdimage-imx6.wks"

# Add any optional config files that might be present e.g. in other layers
include conf/machine/include/dh-imx6-common-extra.inc
include conf/machine/${MACHINE}-extra.conf
