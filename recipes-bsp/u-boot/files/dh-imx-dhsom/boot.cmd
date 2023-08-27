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

# Assure that initrd relocation to the end of DRAM will not interfere
# with application of relocated DT and DTOs at %UBOOT_DTB_LOADADDRESS% , clamp the
# initrd relocation address below UBOOT_DTB_LOADADDRESS = %UBOOT_DTB_LOADADDRESS%.
if test -z "${initrd_high}" ; then
  setenv initrd_high %UBOOT_DTB_LOADADDRESS%
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
  fi
fi

# A custom script exists to load DTOs
if test -n "${loaddtoscustom}" ; then
  if test -z "${loaddtos}" ; then
    echo "Using base DT from fitImage default configuration as fallback."
    fdt addr ${loadaddr}
    fdt get value loaddtos /configurations default
    setenv loaddtos "#${loaddtos}"
    echo "To select different base DT to be adjusted using 'loaddtoscustom'"
    echo "script and passed to Linux kernel, set 'loaddtos' variable:"
    echo "  => env set loaddtos \#conf@...dtb"
  fi

  # Matches UBOOT_DTB_LOADADDRESS in OE layer machine config
  setenv loadaddrdtb %UBOOT_DTB_LOADADDRESS%
  # Matches UBOOT_DTBO_LOADADDRESS in OE layer machine config
  setenv loadaddrdtbo %UBOOT_DTBO_LOADADDRESS%

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

  # Run the custom DTO loader script
  #
  # In case 'loaddtos' variable is set, then the 'fdt' command is already
  # configured to point to a DT, on top of which all the DTOs present in
  # the fitImage and selected by the 'loaddtos' are applied. Hence, the
  # user is now free to apply any additional custom DTOs loaded from any
  # other source.
  #
  # In case 'loaddtos' variable is not set, the 'loaddtoscustom' script
  # must configure the 'fdt' command to point to the custom DT.
  run loaddtoscustom
  if test -z "${bootm_args}" ; then
    setenv bootm_args "${loadaddr} - ${fdtaddr}"
  fi
else
  setenv bootm_args "${loadaddr}${loaddtos}"
fi

echo "Booting the Linux kernel..." \
&& bootm ${bootm_args}
