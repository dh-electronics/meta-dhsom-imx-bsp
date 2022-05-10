LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

DESCRIPTION = "Install splash images"

SRC_URI = "file://800x480_done.bmp \
           file://800x480_error.bmp \
           file://800x480_progress.bmp \
           file://800x480_splash_DHCOM_iMX6.bmp"

inherit deploy

do_deploy () {
    install -d ${DEPLOYDIR}
    install -m 0644 ${WORKDIR}/800x480_done.bmp ${DEPLOYDIR}/800x480_done.bmp
    install -m 0644 ${WORKDIR}/800x480_error.bmp ${DEPLOYDIR}/800x480_error.bmp
    install -m 0644 ${WORKDIR}/800x480_progress.bmp ${DEPLOYDIR}/800x480_progress.bmp
    install -m 0644 ${WORKDIR}/800x480_splash_DHCOM_iMX6.bmp ${DEPLOYDIR}/splash.bmp
}

addtask deploy after do_install before do_build

do_compile[noexec] = "1"
do_install[noexec] = "1"
do_populate_sysroot[noexec] = "1"

PACKAGE_ARCH = "${MACHINE_ARCH}"
