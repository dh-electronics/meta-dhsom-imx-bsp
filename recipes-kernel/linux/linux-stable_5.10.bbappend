FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/5.10:${THISDIR}/${PN}/common:"

KBRANCH_dh-imx6-dhsom ?= "linux-5.10.y"
COMPATIBLE_MACHINE = "(dh-imx6-dhsom)"

SRC_URI_append_dh-imx6-dhsom = " \
	file://dh-imx6-common;type=kmeta;destsuffix=dh-imx6-common \
	"

SRC_URI_append_dh-imx6-dhcom-pdk2 = " \
	file://dh-imx6-dhcom-pdk2;type=kmeta;destsuffix=dh-imx6-dhcom-pdk2 \
	"
KERNEL_FEATURES_dh-imx6-dhcom-pdk2 = " dh-imx6-dhcom-pdk2-standard.scc "
