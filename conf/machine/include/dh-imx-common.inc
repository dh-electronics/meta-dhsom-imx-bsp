MACHINEOVERRIDES =. "dh-dhsom:"

MACHINE_FEATURES ?= "apm alsa ext2 keyboard screen serial touchscreen usbgadget usbhost"

# U-Boot bootloader
UBOOT_ENV = "boot"
UBOOT_ENV_SUFFIX = "scr"

PREFERRED_PROVIDER_virtual/bootloader ?= "u-boot-mainline"
PREFERRED_PROVIDER_u-boot ?= "u-boot-mainline"
PREFERRED_PROVIDER_u-boot-native ?= "u-boot-mainline"
PREFERRED_PROVIDER_u-boot-fw-utils ?= "u-boot-mainline-fw-utils"
PREFERRED_PROVIDER_u-boot-fw-utils-native ?= "u-boot-mainline-fw-utils-native"
PREFERRED_PROVIDER_u-boot-tools ?= "u-boot-mainline-tools"
PREFERRED_PROVIDER_u-boot-tools-native ?= "u-boot-mainline-tools-native"
PREFERRED_VERSION_u-boot-mainline ?= "2022.01%"
PREFERRED_VERSION_u-boot-mainline-native ?= "2022.01%"
PREFERRED_VERSION_u-boot-mainline-fw-utils ?= "2022.01%"
PREFERRED_VERSION_u-boot-mainline-fw-utils-native ?= "2022.01%"
PREFERRED_VERSION_u-boot-mainline-tools ?= "2022.01%"
PREFERRED_VERSION_u-boot-mainline-tools-native ?= "2022.01%"

# Linux kernel
KERNEL_IMAGETYPE = "fitImage"
KERNEL_CLASSES += " kernel-fitimage "
KERNEL_MODULES_AUTOLOAD += " etnaviv "

PREFERRED_PROVIDER_virtual/kernel ?= "linux-stable"
PREFERRED_VERSION_linux-stable ?= "5.10%"

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
	u-boot-default-env \
	"

# List of images to be built
IMAGE_FSTYPES ?= "tar.xz wic.xz wic.gz"
INITRAMFS_FSTYPES ?= "cpio.xz"

EXTRA_IMAGEDEPENDS += "virtual/bootloader"
IMAGE_BOOT_FILES ?= "${KERNEL_IMAGETYPE}"
IMAGE_INSTALL:append = " kernel-devicetree kernel-image-fitimage virtual/bootloader "
do_image_wic[depends] += "mtools-native:do_populate_sysroot dosfstools-native:do_populate_sysroot virtual/bootloader:do_deploy"

# Add any optional config files that might be present e.g. in other layers
include conf/machine/${MACHINE}-extra.conf
