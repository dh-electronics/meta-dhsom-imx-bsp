MACHINEOVERRIDES =. "dh-dhsom:dh-imx-dhsom:"

MACHINE_FEATURES ?= "apm alsa ext2 keyboard screen serial touchscreen usbgadget usbhost"

# U-Boot bootloader
UBOOT_ENV = "boot"
UBOOT_ENV_SUFFIX = "scr"

PREFERRED_PROVIDER_virtual/bootloader ?= "u-boot-mainline"
PREFERRED_PROVIDER_u-boot ?= "u-boot-mainline"
PREFERRED_PROVIDER_u-boot-native ?= "u-boot-mainline"
PREFERRED_PROVIDER_u-boot-fw-utils ?= "u-boot-mainline-fw-utils"
PREFERRED_PROVIDER_u-boot-fw-utils-native ?= "u-boot-mainline-fw-utils-native"
PREFERRED_PROVIDER_u-boot-mkimage-native ?= "u-boot-mainline-tools-native"
PREFERRED_PROVIDER_u-boot-tools ?= "u-boot-mainline-tools"
PREFERRED_PROVIDER_u-boot-tools-native ?= "u-boot-mainline-tools-native"
PREFERRED_VERSION_u-boot-mainline ?= "2025.07%"
PREFERRED_VERSION_u-boot-mainline-native ?= "2025.07%"
PREFERRED_VERSION_u-boot-mainline-fw-utils ?= "2025.07%"
PREFERRED_VERSION_u-boot-mainline-fw-utils-native ?= "2025.07%"
PREFERRED_VERSION_u-boot-mainline-tools ?= "2025.07%"
PREFERRED_VERSION_u-boot-mainline-tools-native ?= "2025.07%"

# Linux kernel
KERNEL_IMAGETYPE = "fitImage"
KERNEL_CLASSES += " kernel-fitimage "

# WPE (from meta-webkit)
PREFERRED_RPROVIDER_virtual/wpebackend ?= "wpebackend-fdo"

# Ship kernel modules
MACHINE_ESSENTIAL_EXTRA_RDEPENDS += " \
	kernel-modules kernel-devicetree \
	u-boot-default-env \
	"

# List of images to be built
IMAGE_FSTYPES ?= "tar.zst wic.zst wic.gz wic.bmap"
INITRAMFS_FSTYPES ?= "cpio.zst"

DH_UBOOT_RECIPE ?= "u-boot-mainline"
EXTRA_IMAGEDEPENDS += "${DH_UBOOT_RECIPE}"
IMAGE_BOOT_FILES ?= "${KERNEL_IMAGETYPE}"
IMAGE_INSTALL:append = " kernel-devicetree kernel-image-fitimage ${DH_UBOOT_RECIPE} "
do_image_wic[depends] += "mtools-native:do_populate_sysroot dosfstools-native:do_populate_sysroot ${DH_UBOOT_RECIPE}:do_deploy"

# Add any optional config files that might be present e.g. in other layers
include conf/machine/${MACHINE}-extra.conf
