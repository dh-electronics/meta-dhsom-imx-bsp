require recipes-kernel/linux/linux-yocto.inc

SUMMARY = "Legacy downstream Linux kernel version"

LICENSE = "${@'GPLv2' if (d.getVar('LAYERSERIES_CORENAMES') in ["dunfell"]) else 'GPL-2.0-only'}"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0${@'' if (d.getVar('LAYERSERIES_CORENAMES') in ["dunfell"]) else '-only'};md5=801f80980d171dd6425610833a22dbe6"

DEPENDS:append = " lzop-native"

PV = "${LINUX_VERSION}+git${SRCPV}"

# board specific branches
KBRANCH = "release/5.10.106_dhsom/20220324"

SRC_URI = "git://github.com/dh-electronics/linux-imx6qdl.git;protocol=https;name=machine;branch=${KBRANCH};"

SRCREV_machine = "ff31a486a58449b7d645399fc6c2b40108abe799"

LINUX_VERSION ?= "5.10.106"

# use in-tree-defconfig
KCONFIG_MODE = "--alldefconfig"
KBUILD_DEFCONFIG = "imx6x_dhsom_defconfig"

LINUX_VERSION_EXTENSION ?= "-imx6x-dhsom"
