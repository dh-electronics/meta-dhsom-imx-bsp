FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

BPV := "${@'.'.join(d.getVar('PV').split('.')[0:2])}"
KBRANCH:dh-imx8mp-dhsom ?= "linux-6.0.y"
KMACHINE:dh-imx8mp-dhsom ?= "dh-imx8mp-dhsom"
COMPATIBLE_MACHINE:dh-imx8mp-dhsom = "(dh-imx8mp-dhsom)"

DEPENDS:append:dh-imx8mp-dhsom = " lzop-native "
SRC_URI:append:dh-imx8mp-dhsom = " \
	file://${BPV}/dh-imx8mp-dhsom;type=kmeta;destsuffix=${BPV}/dh-imx8mp-dhsom \
	file://common/dh-imx8mp-dhsom;type=kmeta;destsuffix=common/dh-imx8mp-dhsom \
	"
KERNEL_FEATURES:dh-imx8mp-dhsom = " dh-imx8mp-dhsom-standard.scc "
