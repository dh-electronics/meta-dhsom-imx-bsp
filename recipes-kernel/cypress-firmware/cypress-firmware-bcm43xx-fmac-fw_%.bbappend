do_install:append:dh-imx6ull-dhcom-drc02 () {
	# Symlink the firmware name to match board type
	ln -s brcmfmac43430-sdio.bin \
		${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.dh,imx6ull-dhcom-drc02.bin
}

FILES:${PN}-brcm43430-1dx-sdio:append:dh-imx6ull-dhcom-drc02 = " \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.dh,imx6ull-dhcom-drc02.bin \
	"

do_install:append:dh-imx6ull-dhcom-pdk2 () {
	# Symlink the firmware name to match board type
	ln -s brcmfmac43430-sdio.bin \
		${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.dh,imx6ull-dhcom-pdk2.bin
}

FILES:${PN}-brcm43430-1dx-sdio:append:dh-imx6ull-dhcom-pdk2 = " \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.dh,imx6ull-dhcom-pdk2.bin \
	"

do_install:append:dh-imx6ull-dhcom-picoitx () {
	# Symlink the firmware name to match board type
	ln -s brcmfmac43430-sdio.bin \
		${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.dh,imx6ull-dhcom-picoitx.bin
}

FILES:${PN}-brcm43430-1dx-sdio:append:dh-imx6ull-dhcom-picoitx = " \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.dh,imx6ull-dhcom-picoitx.bin \
	"

do_install:append:dh-imx8mp-dhcom-pdk2 () {
	# Symlink the firmware name to match board type
	ln -s brcmfmac4373-sdio.bin \
	      ${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac4373-sdio.dh,imx8mp-dhcom-pdk2.bin
}

FILES:${PN}-bcm4373-2ae-sdio:append:dh-imx8mp-dhcom-pdk2 = " \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac4373-sdio.dh,imx8mp-dhcom-pdk2.bin \
	"

do_install:append:dh-imx8mp-dhcom-pdk3 () {
	# Symlink the firmware name to match board type
	ln -s brcmfmac4373-sdio.bin \
	      ${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac4373-sdio.dh,imx8mp-dhcom-pdk3.bin
}

FILES:${PN}-bcm4373-2ae-sdio:append:dh-imx8mp-dhcom-pdk3 = " \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac4373-sdio.dh,imx8mp-dhcom-pdk3.bin \
	"
