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
