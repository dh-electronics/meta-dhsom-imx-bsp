require recipes-bsp/u-boot/u-boot-common.inc
# tools/binman/binman needs python3-setuptools now
DEPENDS:append = " python3-setuptools-native"

LIC_FILES_CHKSUM = "file://Licenses/README;md5=a2c678cfd4a4d97135585cad908541c6"

# We use the revision in order to avoid having to fetch it from the
# repo during parse

SRCBRANCH = "dev/legacy/2018.05_dhcom"
SRC_URI = "\
    git://github.com/dh-electronics/u-boot-imx6qdl.git;protocol=https;branch=${SRCBRANCH} \
"
SRCREV = "6d7695d86b58549cc596d88d07ce56cd8a06111c"


