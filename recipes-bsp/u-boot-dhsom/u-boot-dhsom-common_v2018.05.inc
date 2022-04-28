require recipes-bsp/u-boot/u-boot-common.inc
# tools/binman/binman needs python3-setuptools now
DEPENDS:append = " python3-setuptools-native"

LIC_FILES_CHKSUM = "file://Licenses/README;md5=a2c678cfd4a4d97135585cad908541c6"

# We use the revision in order to avoid having to fetch it from the
# repo during parse

SRC_URI = "\
    git://git@gitlab.dh-electronics.com/netzsch/u-boot-imx6qdl-netzsch.git;protocol=ssh;branch=release/legacy-netzsch-hmi/2018.05_dhcom/20220411 \
"
#SRCREV = "6d7695d86b58549cc596d88d07ce56cd8a06111c"
SRCREV = "${AUTOREV}"


