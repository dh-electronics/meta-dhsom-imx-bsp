FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

BPV := "${@'.'.join(d.getVar('PV').split('.')[0:2])}"
KBRANCH:dh-imx6-dhsom ?= "linux-${BPV}.y"
KMACHINE:dh-imx6-dhsom ?= "dh-imx6-dhsom"
COMPATIBLE_MACHINE:dh-imx6-dhsom = "(dh-imx6-dhsom)"

DEPENDS:append:dh-imx6-dhsom = " lzop-native "
SRC_URI:append:dh-imx6-dhsom = " \
	file://${BPV}/dh-imx6-dhsom;type=kmeta;destsuffix=${BPV}/dh-imx6-dhsom \
	file://common/dh-imx6-dhsom;type=kmeta;destsuffix=common/dh-imx6-dhsom \
	"
KERNEL_FEATURES:dh-imx6-dhsom = " dh-imx6-dhsom-standard.scc "
