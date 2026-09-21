MACHINEOVERRIDES =. "dh-imx6ull-dhsom:"

require conf/machine/include/dh-imx-common.inc

DEFAULTTUNE ?= "cortexa7thf-neon-vfpv4"
SOC_FAMILY ?= "imx6ull"

# U-Boot bootloader
UBOOT_ENTRYPOINT := "0x80008000"

PREFERRED_PROVIDER_virtual/bootloader := "u-boot-dhsom"
PREFERRED_PROVIDER_u-boot := "u-boot-dhsom"
PREFERRED_VERSION_u-boot-dhsom := "2018.05%"

DH_UBOOT_RECIPE = "u-boot-dhsom"
require conf/machine/include/dh-imx6-common.inc
require conf/machine/include/arm/armv7a/tune-cortexa7.inc

# Add any optional config files that might be present e.g. in other layers
include conf/machine/include/dh-imx6-common-extra.inc
include conf/machine/${MACHINE}-extra.conf
