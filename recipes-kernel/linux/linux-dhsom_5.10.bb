require recipes-kernel/linux/linux-yocto.inc

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

PV = "${LINUX_VERSION}+git${SRCPV}"

# board specific branches
KBRANCH = "release/5.10.106_dhsom/20220324"

SRCREV_machine = "ff31a486a58449b7d645399fc6c2b40108abe799"

SRC_URI = "git://github.com/dh-electronics/linux-imx6qdl.git;protocol=https;name=machine;branch=${KBRANCH};"

LINUX_VERSION ?= "5.10.106"

# use in-tree-defconfig
KCONFIG_MODE = "--alldefconfig"
KBUILD_DEFCONFIG = "imx6x_dhsom_defconfig"

LINUX_VERSION_EXTENSION ?= "-imx6x-dhsom"
