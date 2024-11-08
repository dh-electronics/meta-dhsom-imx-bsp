MACHINEOVERRIDES =. "dh-imx6-dhsom:"

require conf/machine/include/dh-imx-mainline.inc
require conf/machine/include/dh-imx-common.inc

DEFAULTTUNE ?= "cortexa9thf-neon"
SOC_FAMILY ?= "imx6"

# U-Boot bootloader
UBOOT_ENTRYPOINT := "0x17800000"
UBOOT_DTB_LOADADDRESS = "0x1ff00000"
UBOOT_DTBO_LOADADDRESS = "0x1ff80000"

# Ship firmware
MACHINE_ESSENTIAL_EXTRA_RDEPENDS += " \
	imx-firmware-vpu-imx6d \
	imx-firmware-vpu-imx6q \
	"

require conf/machine/include/arm/armv7a/tune-cortexa9.inc
require conf/machine/include/dh-imx6-common.inc
