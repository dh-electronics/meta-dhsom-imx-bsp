ARM_INSTRUCTION_SET = "thumb"

require conf/machine/include/soc-family.inc

SERIAL_CONSOLES = "115200;ttymxc0"

# Linux kernel
PREFERRED_VERSION_linux-stable ?= "6.6%"
KERNEL_DEVICETREE_PATH_PREFIX = "${@'nxp/imx/' if (d.getVar('PREFERRED_VERSION_linux-stable') in ["6.6%"]) else ''}"
KERNEL_DTBVENDORED = "0"
KERNEL_DTC_FLAGS += "-@"

# U-Boot bootloader
UBOOT_MAKE_TARGET := "u-boot-with-spl.imx"
UBOOT_BINARY := "u-boot-with-spl.imx"
UBOOT_SUFFIX ?= "imx"

# Ship firmware
MACHINE_ESSENTIAL_EXTRA_RDEPENDS += " \
	imx-firmware-sdma-imx6q \
	"

WKS_FILE ?= "sdimage-imx6.wks"

# Add any optional config files that might be present e.g. in other layers
include conf/machine/include/dh-imx6-common-extra.inc
include conf/machine/${MACHINE}-extra.conf
