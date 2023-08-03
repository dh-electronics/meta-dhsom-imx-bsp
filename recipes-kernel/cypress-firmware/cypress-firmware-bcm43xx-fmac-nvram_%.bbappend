do_install:append:dh-imx6ull-dhsom () {
	# Symlink the firmware name to match kernel fallback
	ln -s brcmfmac43430-sdio.1DX.txt \
		${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.txt
}

FILES:${PN}-bcm43430-1dx-sdio:append:dh-imx6ull-dhsom = " \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.txt \
	"

do_install:append:dh-imx6ull-dhcom-drc02 () {
	# Symlink the firmware name to match board type
	ln -s brcmfmac43430-sdio.1DX.txt \
		${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.dh,imx6ull-dhcom-drc02.txt
}

FILES:${PN}-bcm43430-1dx-sdio:append:dh-imx6ull-dhcom-drc02 = " \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.dh,imx6ull-dhcom-drc02.txt \
	"

do_install:append:dh-imx6ull-dhcom-pdk2 () {
	# Symlink the firmware name to match board type
	ln -s brcmfmac43430-sdio.1DX.txt \
		${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.dh,imx6ull-dhcom-pdk2.txt
}

FILES:${PN}-bcm43430-1dx-sdio:append:dh-imx6ull-dhcom-pdk2 = " \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.dh,imx6ull-dhcom-pdk2.txt \
	"

do_install:append:dh-imx6ull-dhcom-picoitx () {
	# Symlink the firmware name to match board type
	ln -s brcmfmac43430-sdio.1DX.txt \
		${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.dh,imx6ull-dhcom-picoitx.txt
}

FILES:${PN}-bcm43430-1dx-sdio:append:dh-imx6ull-dhcom-picoitx = " \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.dh,imx6ull-dhcom-picoitx.txt \
	"

do_install:append:dh-imx8mp-dhcom-pdk2 () {
	# Symlink the firmware name to match kernel fallback
	ln -s brcmfmac4373-sdio.2AE.txt \
	      ${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac4373-sdio.txt
	# Symlink the firmware name to match board type
	ln -s brcmfmac4373-sdio.2AE.txt \
	      ${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac4373-sdio.dh,imx8mp-dhcom-pdk2.txt
}

FILES:${PN}-bcm4373-2ae-sdio:append:dh-imx8mp-dhcom-pdk2 = " \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac4373-sdio.txt \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac4373-sdio.dh,imx8mp-dhcom-pdk2.txt \
	"

do_install:append:dh-imx8mp-dhcom-pdk3 () {
	# Symlink the firmware name to match kernel fallback
	ln -s brcmfmac4373-sdio.2AE.txt \
	      ${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac4373-sdio.txt
	# Symlink the firmware name to match board type
	ln -s brcmfmac4373-sdio.2AE.txt \
	      ${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac4373-sdio.dh,imx8mp-dhcom-pdk3.txt
}

FILES:${PN}-bcm4373-2ae-sdio:append:dh-imx8mp-dhcom-pdk3 = " \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac4373-sdio.txt \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac4373-sdio.dh,imx8mp-dhcom-pdk3.txt \
	"
