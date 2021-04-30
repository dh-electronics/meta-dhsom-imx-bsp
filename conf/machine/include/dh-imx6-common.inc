DEFAULTTUNE ?= "cortexa9thf-neon"
SOC_FAMILY ?= "imx6"

MACHINEOVERRIDES =. "dh-imx6-dhsom:"

ARM_INSTRUCTION_SET = "thumb"

require conf/machine/include/tune-cortexa9.inc
require conf/machine/include/soc-family.inc

MACHINE_FEATURES ?= "apm alsa ext2 keyboard screen serial touchscreen usbgadget usbhost"

SERIAL_CONSOLE = "115200 ttymxc0"

# U-Boot bootloader
UBOOT_ENTRYPOINT := "0x17800000"
UBOOT_MAKE_TARGET := "u-boot-with-spl.imx"
UBOOT_BINARY := "u-boot-with-spl.imx"
UBOOT_SUFFIX ?= "imx"
UBOOT_MACHINE = "dh_imx6_defconfig"
UBOOT_ENV = "boot"
UBOOT_ENV_SUFFIX = "scr"
UBOOT_DTB_LOADADDRESS = "0x1ff00000"
UBOOT_DTBO_LOADADDRESS = "0x1ff80000"

PREFERRED_PROVIDER_virtual/bootloader ?= "u-boot-mainline"
PREFERRED_PROVIDER_u-boot ?= "u-boot-mainline"
PREFERRED_PROVIDER_u-boot-native ?= "u-boot-mainline"
PREFERRED_PROVIDER_u-boot-fw-utils ?= "u-boot-mainline-fw-utils"
PREFERRED_PROVIDER_u-boot-fw-utils-native ?= "u-boot-mainline-fw-utils-native"
PREFERRED_PROVIDER_u-boot-tools ?= "u-boot-mainline-tools"
PREFERRED_PROVIDER_u-boot-tools-native ?= "u-boot-mainline-tools-native"
PREFERRED_VERSION_u-boot ?= "2021.01%"
PREFERRED_VERSION_u-boot-native ?= "2021.01%"
PREFERRED_VERSION_u-boot-fw-utils ?= "2021.01%"
PREFERRED_VERSION_u-boot-fw-utils-native ?= "2021.01%"
PREFERRED_VERSION_u-boot-mainline-tools ?= "2021.01%"
PREFERRED_VERSION_u-boot-mainline-tools-native ?= "2021.01%"

# Linux kernel
KERNEL_IMAGETYPE = "fitImage"
KERNEL_CLASSES += " kernel-fitimage "
KERNEL_MODULES_AUTOLOAD += " etnaviv "

PREFERRED_PROVIDER_virtual/kernel ?= "linux-stable"
PREFERRED_VERSION_linux-stable ?= "5.10%"
PREFERRED_VERSION_linux-yocto ?= "5.10%"

# Mesa
PREFERRED_PROVIDER_virtual/egl ?= "mesa-mainline"
PREFERRED_PROVIDER_virtual/libgl ?= "mesa-mainline"
PREFERRED_PROVIDER_virtual/libgl-native ?= "mesa-mainline-native"
PREFERRED_PROVIDER_virtual/nativesdk-libgl ?= "nativesdk-mesa-mainline"
PREFERRED_PROVIDER_virtual/libgles1 ?= "mesa-mainline"
PREFERRED_PROVIDER_virtual/libgles2 ?= "mesa-mainline"
PREFERRED_PROVIDER_virtual/mesa ?= "mesa-mainline"
PREFERRED_PROVIDER_nativesdk-mesa ?= "nativesdk-mesa-mainline"

# WPE (from meta-webkit)
PREFERRED_RPROVIDER_virtual/wpebackend ?= "wpebackend-fdo"

# Ship kernel modules
MACHINE_ESSENTIAL_EXTRA_RDEPENDS += " \
	kernel-modules kernel-devicetree \
	firmware-imx-sdma-imx6q u-boot-default-env \
	vpu-firmware \
	"

# List of images to be built
IMAGE_FSTYPES ?= "tar.xz wic.xz wic.gz"
INITRAMFS_FSTYPES ?= "cpio.xz"

EXTRA_IMAGEDEPENDS += "virtual/bootloader"
WKS_FILE = "sdimage-imx6.wks"
IMAGE_BOOT_FILES ?= "${KERNEL_IMAGETYPE}"
IMAGE_INSTALL_append = " kernel-devicetree kernel-image-fitimage virtual/bootloader "
do_image_wic[depends] += "mtools-native:do_populate_sysroot dosfstools-native:do_populate_sysroot virtual/bootloader:do_deploy"

# Add any optional config files that might be present e.g. in other layers
include conf/machine/include/dh-imx6-common-extra.inc
include conf/machine/${MACHINE}-extra.conf
