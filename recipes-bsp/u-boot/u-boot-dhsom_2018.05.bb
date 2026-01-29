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
SRCREV = "2ac5fef63c95f503eb0231976ca3709d44de7bb0"
SRCREV:dh-imx6ull-dhsom = "9725d01f823432179428350dd412e15525f44404"
