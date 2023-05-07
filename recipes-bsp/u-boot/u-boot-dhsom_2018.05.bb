require recipes-bsp/u-boot/u-boot-common.inc
require recipes-bsp/u-boot/u-boot-mainline.inc
require u-boot-dhsom-common.inc

LICENSE = "${@'GPLv2+' if (d.getVar('LAYERSERIES_CORENAMES') in ["dunfell"]) else 'GPL-2.0-or-later'}"
LIC_FILES_CHKSUM = "file://Licenses/README;md5=a2c678cfd4a4d97135585cad908541c6"

DEPENDS += "bc-native dtc-native"

SRC_URI = "\
    git://github.com/dh-electronics/u-boot-imx6qdl.git;protocol=https;nobranch=1 \
"

# We use the revision in order to avoid having to fetch it from the
# repo during parse
PV .= "+git${SRCPV}"
SRCREV = "30ca44e9c81552098548ad902f8e1ab5ffdab97e"
