require recipes-kernel/linux/linux-yocto.inc

SUMMARY = "Legacy downstream Linux kernel version"

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

DEPENDS:append = " lzop-native"

PV = "${LINUX_VERSION}+git${SRCPV}"

# board specific branches
KBRANCH = "release/6.1.80_dhsom/20240315"

SRC_URI = "git://github.com/dh-electronics/linux-imx6qdl.git;protocol=https;name=machine;branch=${KBRANCH};"

SRCREV_machine = "3d7e3946499693422be9a1bc7706b232a33b051c"

LINUX_VERSION ?= "6.1.80"

# use in-tree-defconfig
KCONFIG_MODE = "--alldefconfig"
KBUILD_DEFCONFIG = "imx6x_dhsom_defconfig"

LINUX_VERSION_EXTENSION ?= "-imx6x-dhsom"
