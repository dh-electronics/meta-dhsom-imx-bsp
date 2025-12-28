PERF_SRC:append:dh-imx-dhsom = " ${@'arch/${ARCH}/include/uapi/asm/ arch/arm64/tools' if (d.getVar('LAYERSERIES_CORENAMES') in ["kirkstone"] and d.getVar('PREFERRED_VERSION_linux-stable') not in ["5.10%"]) else ''}"

PACKAGECONFIG:append:dh-imx-dhsom = " jevents"

RDEPENDS:${PN}-tests:append:dh-imx-dhsom = " perl"
