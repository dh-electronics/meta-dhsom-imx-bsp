do_install:append:dh-imx8mp-dhcom-pdk2 () {
	# Symlink the firmware name to match board type
	ln -s brcmfmac4373-sdio.clm_blob \
	      ${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac4373-sdio.dh,imx8mp-dhcom-pdk2.clm_blob
	ln -s brcmfmac4373-sdio.bin \
	      ${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac4373-sdio.dh,imx8mp-dhcom-pdk2.bin
}

FILES:${PN}-bcm4373-sdio:append:dh-imx8mp-dhcom-pdk2 = " \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac4373-sdio.dh,imx8mp-dhcom-pdk2.clm_blob \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac4373-sdio.dh,imx8mp-dhcom-pdk2.bin \
	"

do_install:append:dh-imx8mp-dhcom-pdk3 () {
	# Symlink the firmware name to match board type
	ln -s brcmfmac4373-sdio.clm_blob \
	      ${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac4373-sdio.dh,imx8mp-dhcom-pdk3.clm_blob
	ln -s brcmfmac4373-sdio.bin \
	      ${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac4373-sdio.dh,imx8mp-dhcom-pdk3.bin
}

FILES:${PN}-bcm4373-sdio:append:dh-imx8mp-dhcom-pdk3 = " \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac4373-sdio.dh,imx8mp-dhcom-pdk3.clm_blob \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac4373-sdio.dh,imx8mp-dhcom-pdk3.bin \
	"
