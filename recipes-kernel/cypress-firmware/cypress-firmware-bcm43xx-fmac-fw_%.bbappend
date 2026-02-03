do_install:append:dh-imx6ull-dhcom-drc02 () {
	# Symlink the firmware name to match board type
	ln -s brcmfmac43430-sdio.clm_blob \
		${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.dh,imx6ull-dhcom-drc02.clm_blob
	ln -s brcmfmac43430-sdio.bin \
		${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.dh,imx6ull-dhcom-drc02.bin
	ln -s brcmfmac43439-sdio.clm_blob \
		${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43439-sdio.dh,imx6ull-dhcom-drc02.clm_blob
	ln -s brcmfmac43439-sdio.bin \
		${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43439-sdio.dh,imx6ull-dhcom-drc02.bin
}

FILES:${PN}-bcm43430-1dx-sdio:append:dh-imx6ull-dhcom-drc02 = " \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.dh,imx6ull-dhcom-drc02.clm_blob \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.dh,imx6ull-dhcom-drc02.bin \
	"

FILES:${PN}-bcm43439-1yn-sdio:append:dh-imx6ull-dhcom-drc02 = " \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43439-sdio.dh,imx6ull-dhcom-drc02.clm_blob \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43439-sdio.dh,imx6ull-dhcom-drc02.bin \
	"

do_install:append:dh-imx6ull-dhcom-pdk2 () {
	# Symlink the firmware name to match board type
	ln -s brcmfmac43430-sdio.clm_blob \
		${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.dh,imx6ull-dhcom-pdk2.clm_blob
	ln -s brcmfmac43430-sdio.bin \
		${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.dh,imx6ull-dhcom-pdk2.bin
	ln -s brcmfmac43439-sdio.clm_blob \
		${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43439-sdio.dh,imx6ull-dhcom-pdk2.clm_blob
	ln -s brcmfmac43439-sdio.bin \
		${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43439-sdio.dh,imx6ull-dhcom-pdk2.bin
}

FILES:${PN}-bcm43430-1dx-sdio:append:dh-imx6ull-dhcom-pdk2 = " \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.dh,imx6ull-dhcom-pdk2.clm_blob \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.dh,imx6ull-dhcom-pdk2.bin \
	"

FILES:${PN}-bcm43439-1yn-sdio:append:dh-imx6ull-dhcom-pdk2 = " \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43439-sdio.dh,imx6ull-dhcom-pdk2.clm_blob \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43439-sdio.dh,imx6ull-dhcom-pdk2.bin \
	"

do_install:append:dh-imx6ull-dhcom-picoitx () {
	# Symlink the firmware name to match board type
	ln -s brcmfmac43430-sdio.clm_blob \
		${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.dh,imx6ull-dhcom-picoitx.clm_blob
	ln -s brcmfmac43430-sdio.bin \
		${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.dh,imx6ull-dhcom-picoitx.bin
	ln -s brcmfmac43439-sdio.clm_blob \
		${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43439-sdio.dh,imx6ull-dhcom-picoitx.clm_blob
	ln -s brcmfmac43439-sdio.bin \
		${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43439-sdio.dh,imx6ull-dhcom-picoitx.bin
}

FILES:${PN}-bcm43430-1dx-sdio:append:dh-imx6ull-dhcom-picoitx = " \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.dh,imx6ull-dhcom-picoitx.clm_blob \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.dh,imx6ull-dhcom-picoitx.bin \
	"

FILES:${PN}-bcm43439-1yn-sdio:append:dh-imx6ull-dhcom-picoitx = " \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43439-sdio.dh,imx6ull-dhcom-picoitx.clm_blob \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43439-sdio.dh,imx6ull-dhcom-picoitx.bin \
	"
