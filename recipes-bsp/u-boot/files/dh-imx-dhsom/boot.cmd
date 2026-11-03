if test -n "${distro_bootpart}"; then
  setenv bootpartition "${distro_bootpart}"
else
  setenv bootpartition "${bootpart}"
fi

setenv bootfile boot/fitImage
setenv rootpartition ${bootpartition}

# Handle legacy split boot and root partition layout
if test ! -e ${devtype} ${devnum}:${bootpartition} ${bootfile}; then
	setenv bootfile fitImage
	setexpr rootpartition ${bootpartition} + 1
fi

if test ! -e ${devtype} ${devnum}:${bootpartition} ${bootfile}; then
  echo "This boot medium does not contain a suitable fitImage file for this system."
  echo "devtype=${devtype} devnum=${devnum} partition=${bootpartition} loadaddr=${loadaddr}"
  echo "Aborting boot process."
  exit 1
fi

part uuid ${devtype} ${devnum}:${rootpartition} uuid

# Some IMX6-based systems do not encode the baudrate in the console variable
if test "${console}" = "ttymxc0" && test -n "${baudrate}"; then
  setenv console "${console},${baudrate}"
fi

if test -n "${console}"; then
  setenv bootargs "${bootargs} console=${console}"
fi

setenv bootargs "${bootargs} root=PARTUUID=${uuid} rw rootwait consoleblank=0"

load ${devtype} ${devnum}:${bootpartition} ${loadaddr} ${bootfile}
if test $? != 0 ; then
  echo "Failed to load fitImage file for this system from boot medium."
  echo "devtype=${devtype} devnum=${devnum} partition=${bootpartition} loadaddr=${loadaddr}"
  echo "Aborting boot process."
  exit 2
fi

# If the user did not override the DTOs to be loaded from the fitImage,
# apply DTOs which may be required to operate specific SoM variant or
# board variant.
if test -z "${loaddtos}" ; then
  if test "${board_name}" = "dh_imx8mp" ; then
    fdt addr ${loadaddr}
    fdt get value loaddtos /configurations default
    setenv loaddtos "#${loaddtos}"
    fdt addr ${fdtcontroladdr}
    fdt get value dh_compatible / compatible
    fdt get value dh_phy_mode_eqos /soc@0/bus@30800000/ethernet@30bf0000 phy-mode
    fdt get value dh_phy_mode_fec /soc@0/bus@30800000/ethernet@30be0000 phy-mode
    if test "${dh_phy_mode_eqos}" = "rmii" ; then
      if test "${dh_phy_mode_fec}" = "rmii" ; then
        echo "DH i.MX8M Plus 2x RMII PHY SoM variant detected, applying dual-RMII PHY DTO."
        setenv loaddtos "${loaddtos}#conf-freescale_imx8mp-dhcom-som-overlay-eth2xfast.dtbo"
        if test "${dh_compatible}" = "dh,imx8mp-dhcom-pdk2" -o "${dh_compatible}" = "dh,imx8mp-dhcom-pdk3" ; then
          echo "DH i.MX8M Plus 2x RMII PHY SoM variant on PDK2/PDK3 detected, applying dual-RMII PHY DTO."
          setenv loaddtos "${loaddtos}#conf-freescale_imx8mp-dhcom-pdk-overlay-eth2xfast.dtbo"
        fi
      else
        echo "DH i.MX8M Plus 1x RMII PHY SoM variant detected, applying single-RMII PHY DTO."
        setenv loaddtos "${loaddtos}#conf-freescale_imx8mp-dhcom-som-overlay-eth1xfast.dtbo"
      fi
    fi

    if test "${dh_compatible}" = "dh,imx8mp-dhcom-pdk3" ; then
      i2c dev 4
      i2c mw 0x70 0 4
      if i2c probe 0x24 ; then
        echo "DH i.MX8M Plus on PDK3 rev.200 or newer detected"
      else
        echo "DH i.MX8M Plus on PDK3 rev.100 detected, disabling CSI2 GPIO expander."
        setenv loaddtos "${loaddtos}#conf-freescale_imx8mp-dhcom-pdk3-rev100-overlay.dtbo"
      fi
    fi

    # Determine SoM revision from SoM coding GPIOs
    gpio input GPIO3_25
    setexpr dh_som_rev $? * 2
    gpio input GPIO4_19
    setexpr dh_som_rev ${dh_som_rev} + $?
    setexpr dh_som_rev ${dh_som_rev} * 2
    gpio input GPIO3_14
    setexpr dh_som_rev ${dh_som_rev} + $?

    if test "${dh_som_rev}" = "0" ; then
      echo "DH i.MX8M Plus rev.100 SoM detected, applying rev.100 SoM DTO."
      setenv loaddtos "${loaddtos}#conf-freescale_imx8mp-dhcom-som-overlay-rev100.dtbo"
      if test "${dh_compatible}" = "dh,imx8mp-dhcom-pdk2" ; then
        echo "DH i.MX8M Plus rev.100 SoM on PDK2 detected, applying rev.100 SoM on PDK2 DTO."
        setenv loaddtos "${loaddtos}#conf-freescale_imx8mp-dhcom-pdk2-overlay-rev100.dtbo"
      elif test "${dh_compatible}" = "dh,imx8mp-dhcom-pdk3" ; then
        echo "DH i.MX8M Plus rev.100 SoM on PDK3 detected, applying rev.100 SoM on PDK3 DTO."
        setenv loaddtos "${loaddtos}#conf-freescale_imx8mp-dhcom-pdk3-overlay-rev100.dtbo"
      fi
    fi
  fi
fi

if bootm start ${loadaddr}${loaddtos} ; then ;
  # New enough U-Boot supports safe DTO application, all done.
else
  # Workaround for obsolete U-Boot versions which do not support
  # booting fitImages without hard-coded DT load addresses.
  echo "Manually applying DTOs from fitImage without hard-coded DT load address."
  echo "Please update your U-Boot to a newer version to avoid this workaround."

  # Place DTO load area at 1 MiB aligned offset past the fitImage
  setexpr loadaddrdtbo ${loadaddr} + ${filesize}
  setexpr loadaddrdtbo ${loadaddrdtbo} - 1
  setexpr loadaddrdtbo ${loadaddrdtbo} \| 0xfffff
  setexpr loadaddrdtbo ${loadaddrdtbo} + 1
  # Place DTB apply scratch area at 1 MiB offset past the DTO load area
  setexpr loadaddrdtb ${loadaddrdtbo} + 0x100000

  setexpr loaddtossep gsub '#conf' ' fdt' "${loaddtos}"
  setexpr loaddtb 1

  for i in ${loaddtossep} ; do
    if test ${loaddtb} = 1 ; then
      echo "Using base DT ${i}"
      imxtract ${loadaddr} ${i} ${loadaddrdtb} ;
      fdt addr ${loadaddrdtb}
      fdt resize 0x40000
      setenv loaddtb 0
    else
      echo "Applying DTO ${i}"
      imxtract ${loadaddr} ${i} ${loadaddrdtbo} ;
      fdt apply ${loadaddrdtbo}
    fi
  done

  setenv loaddtb
  setenv loaddtossep
  setenv loadaddrdtbo
  setenv loadaddrdtb
fi

# Assure that initrd relocation to the end of DRAM will not interfere
# with application of relocated DT and DTOs at ${fdtaddr} , clamp the
# initrd relocation address below ${fdtaddr} .
if test -z "${initrd_high}" ; then
  setexpr initrd_high ${fdtaddr} \& 0xffffffffffff0000
fi

# Run the custom DTO loader script
#
# The 'fdt' command is already configured to point to a DT, on top
# of which all the DTOs present in the fitImage and selected by the
# 'loaddtos' are applied. Hence, the user is now free to apply any
# additional custom DTOs loaded from any other source.
if test -n "${loaddtoscustom}" ; then
  run loaddtoscustom
fi

if test -z "${bootm_args}" ; then
  setenv bootm_args "${loadaddr} - ${fdtaddr}"
fi

echo "Booting the Linux kernel..."
bootm ${bootm_args}
