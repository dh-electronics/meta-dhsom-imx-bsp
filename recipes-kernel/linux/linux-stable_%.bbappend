FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

BPV := "${@'.'.join(d.getVar('PV').split('.')[0:2])}"
KBRANCH_dh-imx6-dhsom ?= "linux-${BPV}.y"
COMPATIBLE_MACHINE = "(dh-imx6-dhsom)"

SRC_URI_append_dh-imx6-dhsom = " \
	file://${BPV}/dh-imx6-dhsom;type=kmeta;destsuffix=${BPV}/dh-imx6-dhsom \
	"

SRC_URI_append_dh-imx6-dhcom-pdk2 = " \
	file://common/dh-imx6-dhcom-pdk2;type=kmeta;destsuffix=common/dh-imx6-dhcom-pdk2 \
	"
KERNEL_FEATURES_dh-imx6-dhcom-pdk2 = " dh-imx6-dhcom-pdk2-standard.scc "
