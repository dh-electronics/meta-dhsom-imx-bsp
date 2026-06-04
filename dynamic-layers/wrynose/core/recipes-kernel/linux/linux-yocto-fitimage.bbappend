FIT_UBOOT_ENV:dh-imx-dhsom = "${UBOOT_ENV}.${UBOOT_ENV_SUFFIX}"

python do_compile:prepend:dh-imx-dhsom () {
    import shutil

    bootscr_deploydir = d.getVar('DEPLOY_DIR_IMAGE')
    fit_uboot_env = d.getVar("FIT_UBOOT_ENV")
    shutil.copyfile(os.path.join(bootscr_deploydir, fit_uboot_env), fit_uboot_env)
}

do_compile[depends] += "${@d.getVar('PREFERRED_PROVIDER_virtual/bootloader') + ':do_deploy' if ('dh-imx-dhsom' in d.getVar('MACHINEOVERRIDES', True).split(':')) else ' '}"
