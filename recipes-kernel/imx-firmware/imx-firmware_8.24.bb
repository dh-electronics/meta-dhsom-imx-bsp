SUMMARY = "Firmware files for use with Linux kernel for i.MX CPUs"
SECTION = "kernel"
LICENSE = "Firmware-nxp-imx-firmware"
LICENSE:${PN}-nxp-imx-license = "Firmware-nxp-imx-firmware"
LICENSE:${PN}-sdma-imx6q = "Firmware-nxp-imx-firmware"
LICENSE:${PN}-sdma-imx7d = "Firmware-nxp-imx-firmware"
LICENSE:${PN}-vpu-imx6d = "Firmware-nxp-imx-firmware"
LICENSE:${PN}-vpu-imx6q = "Firmware-nxp-imx-firmware"

LIC_FILES_CHKSUM = "file://COPYING;md5=10c0fda810c63b052409b15a5445671a"

EXTRA_HASH = "fbe0a4c"
SRC_URI = "https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/firmware-imx-${PV}-${EXTRA_HASH}.bin"
SRC_URI[md5sum] = "440b125e897614d77fac663d90bcffc8"
SRC_URI[sha256sum] = "2e27962332197ebebbb30138f6dfb365361d48d7efa565df97c4f79285b1ca50"

S = "${WORKDIR}/firmware-imx-${PV}-${EXTRA_HASH}"

inherit allarch deploy

do_extra_unpack() {
	dd if=${WORKDIR}/firmware-imx-${PV}-${EXTRA_HASH}.bin of=${WORKDIR}/firmware-imx-${PV}-${EXTRA_HASH}.tar.bz2 \
		bs=$(grep -boam 1 'BZh' ${WORKDIR}/firmware-imx-${PV}-${EXTRA_HASH}.bin | cut -d ":" -f 1) \
		skip=1
	tar -C ${WORKDIR} -xf ${WORKDIR}/firmware-imx-${PV}-${EXTRA_HASH}.tar.bz2
}

do_unpack:append() {
    bb.build.exec_func('do_extra_unpack', d)
}

do_compile[noexec] = "1"

do_install() {
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
	install -m 0644 firmware/ddr/synopsys/*.bin ${DEPLOYDIR}
	install -m 0644 firmware/hdmi/cadence/*.bin ${DEPLOYDIR}
}
addtask deploy after do_install before do_build

NO_GENERIC_LICENSE[Firmware-nxp-imx-firmware] = "COPYING"

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
