# Downstream BSP overrides

MACHINEOVERRIDES =. "mx8mp:"

require conf/machine/include/imx-base.inc

IMX_DEFAULT_BOOTLOADER = "u-boot-mainline"
PREFERRED_PROVIDER_virtual/kernel = "linux-imx"
PREFERRED_PROVIDER_virtual/bootloader = "u-boot-mainline"
# This line below makes use of the OVERRIDE expansion priority
# to override final assignment of virtual/bootloader in broken
# meta-imx distro definitions, those assignments should have
# been weak. The ${MACHINE} is one of the last keys in OVERRIDES
# and thus has highest priority just short of "forcevariable".
PREFERRED_PROVIDER_virtual/bootloader:${MACHINE} = "u-boot-mainline"
KERNEL_IMAGETYPE:${MACHINE} = "fitImage"
IMX_DEFAULT_BOOTLOADER:${MACHINE} = "u-boot-mainline"
IMX_DEFAULT_UBOOTTOOLS:${MACHINE} = "u-boot-mainline-tools"
UBOOT_SUFFIX:${MACHINE} = "bin"

SPL_BINARY = "spl/u-boot-spl.bin"

ATF_PLATFORM = "imx8mp"
IMAGE_BOOTLOADER = "imx-boot"
IMXBOOT_TARGETS = "flash_evk"
IMX_BOOT_SOC_TARGET = "iMX8MP"

DDR_FIRMWARE_VERSION = "202006"
DDR_FIRMWARE_NAME = " \
	lpddr4_pmu_train_1d_dmem_${DDR_FIRMWARE_VERSION}.bin \
	lpddr4_pmu_train_1d_imem_${DDR_FIRMWARE_VERSION}.bin \
	lpddr4_pmu_train_2d_dmem_${DDR_FIRMWARE_VERSION}.bin \
	lpddr4_pmu_train_2d_imem_${DDR_FIRMWARE_VERSION}.bin \
"
