require recipes-bsp/u-boot/u-boot-common.inc
require recipes-bsp/u-boot/u-boot-mainline.inc
require u-boot-dhsom-common.inc

SUMMARY = "Legacy downstream U-Boot version"

LICENSE = "GPL-2.0-or-later"
LIC_FILES_CHKSUM = "file://Licenses/README;md5=a2c678cfd4a4d97135585cad908541c6"

DEPENDS += "bc-native dtc-native"

PV .= "+git${SRCPV}"

SRC_URI = "\
    git://github.com/dh-electronics/u-boot-imx6qdl.git;protocol=https;nobranch=1 \
"

# We use the revision in order to avoid having to fetch it from the
# repo during parse
SRCREV = "30ca44e9c81552098548ad902f8e1ab5ffdab97e"
SRCREV:dh-imx6ull-dhsom = "7e1b0c796401a276f568ef96428e34f6cfade180"
