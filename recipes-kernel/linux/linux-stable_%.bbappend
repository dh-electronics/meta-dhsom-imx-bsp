FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

BPV := "${@'.'.join(d.getVar('PV').split('.')[0:2])}"
KBRANCH_dh-imx6-dhsom ?= "linux-${BPV}.y"
KMACHINE_dh-imx6-dhsom ?= "dh-imx6-dhsom"
COMPATIBLE_MACHINE = "(dh-imx6-dhsom)"

SRC_URI_append_dh-imx6-dhsom = " \
	file://${BPV}/dh-imx6-dhsom;type=kmeta;destsuffix=${BPV}/dh-imx6-dhsom \
	file://common/dh-imx6-dhsom;type=kmeta;destsuffix=common/dh-imx6-dhsom \
	"
KERNEL_FEATURES_dh-imx6-dhsom = " dh-imx6-dhsom-standard.scc "
DEPENDS_append_dh-imx6-dhsom = " lzop-native "
