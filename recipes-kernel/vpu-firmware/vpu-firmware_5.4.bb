SUMMARY = "Firmware files for use with Linux kernel for i.MX CPUs"
SECTION = "kernel"

LICENSE = "Proprietary"

LIC_FILES_CHKSUM = "file://LICENSE;md5=64bc85330a2d404dbcbfa50edb54137d"

SRC_URI = "http://www.freescale.com/lgfiles/NMG/MAD/YOCTO/firmware-imx-${PV}.bin"
SRC_URI[md5sum] = "dae846ca2fc4504067f725f501491adf"
SRC_URI[sha256sum] = "c5bd4bff48cce9715a5d6d2c190ff3cd2262c7196f7facb9b0eda231c92cc223"

do_unpack_extra() {
	head -n 673 ${S}/../firmware-imx-${PV}.bin | tail -n 607 > ${S}/LICENSE
	tail -n +703 ${S}/../firmware-imx-${PV}.bin > ${S}/firmware-imx-${PV}.tar.bz2
	tar -C ${S} -xf ${S}/firmware-imx-${PV}.tar.bz2
}
addtask unpack_extra after do_unpack before do_patch

do_compile() {
}

do_install() {
	install -d  ${D}/lib/firmware/
	install -d  ${D}/lib/firmware/imx/
	install -d  ${D}/lib/firmware/imx/vpu/
	cp -r ${S}/firmware-imx-${PV}/firmware/vpu/*.bin ${D}/lib/firmware/imx/vpu/
	# FIXME: Linux 4.4 expects this filename
	cp -r ${S}/firmware-imx-${PV}/firmware/vpu/vpu_fw_imx6q.bin ${D}/lib/firmware/vpu_fw_imx6q.bin
}

FILES:${PN} += "/lib/firmware/imx/vpu/* /lib/firmware/vpu_fw_imx6q.bin"
