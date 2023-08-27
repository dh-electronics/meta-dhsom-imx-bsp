do_install:append:dh-imx6ull-dhcom-drc02 () {
	# Symlink the firmware name to match board type
	ln -s CYW43430A1.1DX.hcd \
	      ${D}${nonarch_base_libdir}/firmware/brcm/BCM43430A1.dh,imx6ull-dhcom-drc02.hcd
}

FILES:${PN}-bcm4343a1:append:dh-imx6ull-dhcom-drc02 = " \
	${nonarch_base_libdir}/firmware/brcm/BCM43430A1.dh,imx6ull-dhcom-drc02.hcd \
	"

do_install:append:dh-imx6ull-dhcom-pdk2 () {
	# Symlink the firmware name to match board type
	ln -s CYW43430A1.1DX.hcd \
	      ${D}${nonarch_base_libdir}/firmware/brcm/BCM43430A1.dh,imx6ull-dhcom-pdk2.hcd
}

FILES:${PN}-bcm4343a1:append:dh-imx6ull-dhcom-pdk2 = " \
	${nonarch_base_libdir}/firmware/brcm/BCM43430A1.dh,imx6ull-dhcom-pdk2.hcd \
	"

do_install:append:dh-imx6ull-dhcom-picoitx () {
	# Symlink the firmware name to match board type
	ln -s CYW43430A1.1DX.hcd \
	      ${D}${nonarch_base_libdir}/firmware/brcm/BCM43430A1.dh,imx6ull-dhcom-picoitx.hcd
}

FILES:${PN}-bcm4343a1:append:dh-imx6ull-dhcom-picoitx = " \
	${nonarch_base_libdir}/firmware/brcm/BCM43430A1.dh,imx6ull-dhcom-picoitx.hcd \
	"

do_install:append:dh-imx8mp-dhcom-pdk2 () {
	# Symlink the firmware name to match board type
	ln -s BCM4373A0.2AE.hcd \
	      ${D}${nonarch_base_libdir}/firmware/brcm/BCM4373A0.dh,imx8mp-dhcom-pdk2.hcd
}

FILES:${PN}-bcm4373a0-2ae:append:dh-imx8mp-dhcom-pdk2 = " \
	${nonarch_base_libdir}/firmware/brcm/BCM4373A0.dh,imx8mp-dhcom-pdk2.hcd \
	"

do_install:append:dh-imx8mp-dhcom-pdk3 () {
	# Symlink the firmware name to match board type
	ln -s BCM4373A0.2AE.hcd \
	      ${D}${nonarch_base_libdir}/firmware/brcm/BCM4373A0.dh,imx8mp-dhcom-pdk3.hcd
}

FILES:${PN}-bcm4373a0-2ae:append:dh-imx8mp-dhcom-pdk3 = " \
	${nonarch_base_libdir}/firmware/brcm/BCM4373A0.dh,imx8mp-dhcom-pdk3.hcd \
	"
