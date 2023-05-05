FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

KBRANCH:dh-imx-dhsom ?= "linux-6.1.y"
KMACHINE:dh-imx6-dhsom ?= "dh-imx6-dhsom"
KMACHINE:dh-imx6ull-dhsom ?= "dh-imx6ull-dhsom"
KMACHINE:dh-imx8mp-dhsom ?= "dh-imx8mp-dhsom"
COMPATIBLE_MACHINE:dh-imx6-dhsom = "(dh-imx6-dhsom)"
COMPATIBLE_MACHINE:dh-imx6ull-dhsom = "(dh-imx6ull-dhsom)"
COMPATIBLE_MACHINE:dh-imx8mp-dhsom = "(dh-imx8mp-dhsom)"

DEPENDS:append:dh-imx-dhsom = " lzop-native "

SRC_URI:append:dh-imx6-dhsom = " \
	file://${BPV}/dh-imx6-dhsom;type=kmeta;destsuffix=${BPV}/dh-imx6-dhsom \
	file://common/dh-imx6-dhsom;type=kmeta;destsuffix=common/dh-imx6-dhsom \
	"
KERNEL_FEATURES:dh-imx6-dhsom = " dh-imx6-dhsom-standard.scc "

SRC_URI:append:dh-imx6ull-dhsom = " \
	file://${BPV}/dh-imx6ull-dhsom;type=kmeta;destsuffix=${BPV}/dh-imx6ull-dhsom \
	file://common/dh-imx6ull-dhsom;type=kmeta;destsuffix=common/dh-imx6ull-dhsom \
	"
KERNEL_FEATURES:dh-imx6ull-dhsom = " dh-imx6ull-dhsom-standard.scc "

SRC_URI:append:dh-imx8mp-dhsom = " \
	file://${BPV}/dh-imx8mp-dhsom;type=kmeta;destsuffix=${BPV}/dh-imx8mp-dhsom \
	file://common/dh-imx8mp-dhsom;type=kmeta;destsuffix=common/dh-imx8mp-dhsom \
	"
KERNEL_FEATURES:dh-imx8mp-dhsom = " dh-imx8mp-dhsom-standard.scc "
