SUMMARY = "Firmware files for use with Linux kernel for i.MX CPUs"
SECTION = "kernel"
LICENSE = "Firmware-nxp-imx-firmware"
LICENSE:${PN}-nxp-imx-license = "Firmware-nxp-imx-firmware"
LICENSE:${PN}-sdma-imx6q = "Firmware-nxp-imx-firmware"
LICENSE:${PN}-sdma-imx7d = "Firmware-nxp-imx-firmware"
LICENSE:${PN}-vpu-imx6d = "Firmware-nxp-imx-firmware"
LICENSE:${PN}-vpu-imx6q = "Firmware-nxp-imx-firmware"

LIC_FILES_CHKSUM = "file://firmware-imx-${PV}/COPYING;md5=63a38e9f392d8813d6f1f4d0d6fbe657"

SRC_URI = "http://www.freescale.com/lgfiles/NMG/MAD/YOCTO/firmware-imx-${PV}.bin"
SRC_URI[md5sum] = "25c50f3371450b2324401ee06ff1bf6a"
SRC_URI[sha256sum] = "f6dc6a5c8fd9b913a15360d3ccd53d188db05a08a8594c518e57622478c72383"

inherit allarch deploy

do_extra_unpack() {
	dd if=${S}/../firmware-imx-${PV}.bin of=${S}/firmware-imx-${PV}.tar.bz2 \
		bs=$(grep -boam 1 'BZh' ${S}/../firmware-imx-${PV}.bin | cut -d ":" -f 1) \
		skip=1
	tar -C ${S} -xf ${S}/firmware-imx-${PV}.tar.bz2
}
addtask extra_unpack after do_unpack before do_patch

do_compile[noexec] = "1"

do_install() {
	cd ${S}/firmware-imx-${PV}/
	install -d ${D}${nonarch_base_libdir}/firmware/

	# License
	install -d ${D}${nonarch_base_libdir}/firmware/imx/
	install -m 0644 COPYING ${D}${nonarch_base_libdir}/firmware/imx/

	# SDMA firmware
	install -d ${D}${nonarch_base_libdir}/firmware/imx/sdma/
	install -m 0644 firmware/sdma/sdma-imx6q.bin ${D}${nonarch_base_libdir}/firmware/imx/sdma/
	install -m 0644 firmware/sdma/sdma-imx7d.bin ${D}${nonarch_base_libdir}/firmware/imx/sdma/

	# CnM Coda VPU firmware
	install -d ${D}${nonarch_base_libdir}/firmware/vpu/
	install -m 0644 firmware/vpu/vpu_fw_imx6d.bin ${D}${nonarch_base_libdir}/firmware/vpu/
	install -m 0644 firmware/vpu/vpu_fw_imx6q.bin ${D}${nonarch_base_libdir}/firmware/vpu/
}

do_deploy() {
	cd ${S}/firmware-imx-${PV}/
	install -m 0644 firmware/ddr/synopsys/*.bin ${DEPLOYDIR}
	install -m 0644 firmware/hdmi/cadence/*.bin ${DEPLOYDIR}
}
addtask deploy after do_install before do_build

NO_GENERIC_LICENSE[Firmware-nxp-imx-firmware] = "firmware-imx-${PV}/COPYING"

ALLOW_EMPTY:${PN} = "1"
PACKAGES = " \
	${PN}-nxp-imx-license \
	${PN}-sdma-imx6q ${PN}-sdma-imx7d \
	${PN}-vpu-imx6d ${PN}-vpu-imx6q \
	"

FILES:${PN}-nxp-imx-license = "${nonarch_base_libdir}/firmware/imx/COPYING"
FILES:${PN}-sdma-imx6q = " ${nonarch_base_libdir}/firmware/imx/sdma/sdma-imx6q.bin "
FILES:${PN}-sdma-imx7d = " ${nonarch_base_libdir}/firmware/imx/sdma/sdma-imx7d.bin "
FILES:${PN}-vpu-imx6d = " ${nonarch_base_libdir}/firmware/vpu/vpu_fw_imx6d.bin "
FILES:${PN}-vpu-imx6q = " ${nonarch_base_libdir}/firmware/vpu/vpu_fw_imx6q.bin "

RREPLACES:${PN}-sdma-imx6q = "linux-firmware-imx-sdma-imx6q"
RREPLACES:${PN}-sdma-imx7d = "linux-firmware-imx-sdma-imx7d"

RDEPENDS:${PN}-sdma-imx6q += "${PN}-nxp-imx-license"
RDEPENDS:${PN}-sdma-imx7d += "${PN}-nxp-imx-license"
RDEPENDS:${PN}-vpu-imx6d += "${PN}-nxp-imx-license"
RDEPENDS:${PN}-vpu-imx6q += "${PN}-nxp-imx-license"
