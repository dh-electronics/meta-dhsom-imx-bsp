i.MX8M Plus DHCOM SoM on DH PDK2 carrier board
==============================================

# Initial board setup

This section explains how to perform initial hardware setup, how to
assemble the hardware, which cables to connect to which ports, how to
power the hardware on, and finally how to obtain serial console access.

## Insert SoM

Insert SoM provided with the carrier board into socket `U38`.
It is likely the SoM is already populated.

## Connect serial console cable

Connect serial console RS232 cable into `RS232 UART1` DB9 plug `X8`.
This is RS232 up to 12V voltage level connection.

## Connect ethernet cables (optional)

Connect up to one ethernet cable to dual stacked ethernet jack
`100MB Ethernet` `X5`.

## Connect USB OTG cables (optional)

Connect USB OTG cable between host PC and carrier board into plug
`USB OTG` `X14`.

## Connect power supply

Connect provided 24V/1A power supply into barrel jack `X24` or
compatible supply into plug `X23`.

## Start terminal emulator

Start terminal emulator to access serial console. Suitable tools include
any of `minicom`, `picocom`, `screen`, and many others. The serial console
settings are 115200 Baud 8N1 , HW and SW flow control disabled .

At this point, power on the system to validate serial console access. The
bootloader console should be printed on the serial console in a few seconds
after power on.

# System software boot

This system uses the U-Boot distro bootcommand to detect and control bootable
devices and boot from those devices.

The order in which boot devices are tested is stored in U-Boot `boot_targets`
variable. This variable can be overridden to configure different boot order.
The default setting is as follows:

```
u-boot=> env print boot_targets
boot_targets=mmc1 mmc0 mmc2 usb0 pxe
```

To boot only from microSD card, override `boot_targets` variable as follows:
```
u-boot=> env set boot_targets mmc0
u-boot=> boot
```

To boot only from eMMC card, override `boot_targets` variable as follows:
```
u-boot=> env set boot_targets mmc1
u-boot=> boot
```

To boot only from USB stick, override `boot_targets` variable as follows:
```
u-boot=> env set boot_targets usb0
u-boot=> boot
```

The change to `boot_targets` is discarded after the system booted. To make
the boot order change persistent in U-Boot environment, perform the change
and save U-Boot environment as follows:
```
u-boot=> env set boot_targets mmc0
u-boot=> env save
u-boot=> env save
u-boot=> boot
```

# System software build

The OE build of this layer can be set up either manually or automatically using
the [KAS](https://github.com/siemens/kas) tool. Both options yield equal result.
For details, please refer to [kas-dhsom](https://github.com/dh-electronics/kas-dhsom)
and top level README in this OE layer.

# System software installation

## Operating system image installation

The operating system image can be installed onto either microSD card or
into eMMC USER hardware partition.

The operating system image installation into either media can be performed
from within U-Boot itself using USB OTG UMS upload, or using microSD or SD
card reader on a host PC, or from running Linux userspace.

### Operating system image installation (from U-Boot using USB OTG UMS upload)

The USB OTG UMS USB Mass Storage mode exports the storage media on board
as a USB Mass Storage device to the host PC. The host PC can access the
storage as any other USB attached mass storage device and read and write
data from and to it.

Power on the system. Enter U-Boot console by pressing any key at prompt:
```
Hit any key to stop autoboot:
```

The system drops into U-Boot shell instantly. U-Boot shell on this system
looks as follows:
```
u-boot=>
```

Use one of the following commands to start UMS on USB OTG port and
export a storage device.
```
# microSD on DHCOM
u-boot=> ums 0 mmc 0
# eMMC on DHCOM
u-boot=> ums 0 mmc 1
```

The USB mass storage device will now enumerate on the host PC as follows:
```
host$ dmesg -w
usb 5-2.2.2.1: new high-speed USB device number 106 using xhci_hcd
usb 5-2.2.2.1: New USB device found, idVendor=0483, idProduct=5720, bcdDevice= 2.00
usb 5-2.2.2.1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
usb 5-2.2.2.1: Product: USB download gadget
usb 5-2.2.2.1: Manufacturer: DH electronics
usb 5-2.2.2.1: SerialNumber: 003800000000000012345678
usb-storage 5-2.2.2.1:1.0: USB Mass Storage device detected
scsi host3: usb-storage 5-2.2.2.1:1.0
scsi 3:0:0:0: Direct-Access     Linux    UMS disk 0       ffff PQ: 0 ANSI: 2
sd 3:0:0:0: Attached scsi generic sg4 type 0
sd 3:0:0:0: [sdx] 124735488 512-byte logical blocks: (63.9 GB/59.5 GiB)
sd 3:0:0:0: [sdx] Write Protect is off
sd 3:0:0:0: [sdx] Mode Sense: 0f 00 00 00
sd 3:0:0:0: [sdx] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
GPT:Primary header thinks Alt. header is not at the end of the disk.
GPT:3203785 != 124735487
GPT:Alternate GPT header not at the end of the disk.
GPT:3203785 != 124735487
GPT: Use GNU Parted to correct GPT errors.
 sdx: sdx1 sdx2 sdx3 sdx4
sd 3:0:0:0: [sdx] Attached SCSI removable disk
```

Notice that in the aforementioned case, the device is enumerated as block
device `/dev/sdx` on the host PC. This may differ on other host PCs, make
sure the correct block device is used for image installation below. Using
incorrect block device may lead to data loss on the host PC.

Install system image into the block device. It is recommended to use
[bmaptool](https://github.com/yoctoproject/bmaptool) to expedite the
installation by skipping unused blocks. It is recommended to use up
to date bmaptool version at least 3.6.0 which supports decompression
of ZSTD compressed images, otherwise it is necessary to decompress the
ZSTD compressed images first, as follows:
```
host$ zstd -d dh-image-demo-dh-imx8mp-dhcom-pdk2.rootfs.wic.zst
```

To prevent any MBR or GPT contamination, it is recommended to erase
previous MBR and GPT partition tables:
```
host$ sgdisk -Z /dev/sdx

host$ fdisk /dev/sdx
Command (m for help): x                     # x to enter expert menu
Expert command (m for help): i              # i to change identifier
Enter the new disk identifier: 0x1234abcd   # pick random identifier
Expert command (m for help): r              # r to return to main menu
Command (m for help): w                     # w to write change to MBR
```

Use bmaptool to write system image into block device as follows:
```
host$ bmaptool copy --bmap \
    dh-image-demo-dh-imx8mp-dhcom-pdk2.rootfs.wic.bmap \
    dh-image-demo-dh-imx8mp-dhcom-pdk2.rootfs.wic.zst \
    /dev/sdx
bmaptool: info: block map format version 2.0
bmaptool: info: 400474 blocks of size 4096 (1.5 GiB), mapped 246005 blocks (961.0 MiB or 61.4%)
bmaptool: info: copying image 'dh-image-demo-dh-imx8mp-dhcom-pdk2.rootfs.wic' to block device '/dev/sdx' using bmap file 'dh-image-demo-dh-imx8mp-dhcom-pdk2.rootfs.wic.bmap'
bmaptool: info: 100% copied
bmaptool: info: synchronizing '/dev/sdx'
bmaptool: info: copying time: 13.2s, copying speed 72.5 MiB/sec
```

It is equally possible to use plain `dd` to write the decompressed
system image into the block device as follows:
```
host$ dd if=dh-image-demo-dh-imx8mp-dhcom-pdk2.rootfs.wic \
         of=/dev/sdx bs=4M
```

This system uses GPT GUID Partition Table. It is highly recommended to
randomize GUIDs after writing system image to storage to avoid identical
PARTUUID for multiple partitions on different storage media in the system.
Identical PARTUUID for multiple partitions may lead to system using an
unexpected root device, which accidentally shares the same PARTUUID. To
randomize PARTUUID, use the following command:
```
host$ sgdisk -G /dev/sdx
```

Once the installation completed, terminate UMS from U-Boot console
by pressing `Ctrl + C`.

### Operating system image installation (using SD card reader)

This section assumes that the SD card reader is recognized as a block
device `/dev/sdx` on the host PC. This may differ on other host PCs, make
sure the correct block device is used for image installation below. Using
incorrect block device may lead to data loss on the host PC.

Install system image into the block device. It is recommended to use
[bmaptool](https://github.com/yoctoproject/bmaptool) to expedite the
installation by skipping unused blocks. It is recommended to use up
to date bmaptool version at least 3.6.0 which supports decompression
of ZSTD compressed images, otherwise it is necessary to decompress the
ZSTD compressed images first, as follows:
```
host$ zstd -d dh-image-demo-dh-imx8mp-dhcom-pdk2.rootfs.wic.zst
```

To prevent any MBR or GPT contamination, it is recommended to erase
previous MBR and GPT partition tables:
```
host$ sgdisk -Z /dev/sdx

host$ fdisk /dev/sdx
Command (m for help): x                     # x to enter expert menu
Expert command (m for help): i              # i to change identifier
Enter the new disk identifier: 0x1234abcd   # pick random identifier
Expert command (m for help): r              # r to return to main menu
Command (m for help): w                     # w to write change to MBR
```

Use bmaptool to write system image into block device as follows:
```
host$ bmaptool copy --bmap \
    dh-image-demo-dh-imx8mp-dhcom-pdk2.rootfs.wic.bmap \
    dh-image-demo-dh-imx8mp-dhcom-pdk2.rootfs.wic.zst \
    /dev/sdx
bmaptool: info: block map format version 2.0
bmaptool: info: 400474 blocks of size 4096 (1.5 GiB), mapped 246005 blocks (961.0 MiB or 61.4%)
bmaptool: info: copying image 'dh-image-demo-dh-imx8mp-dhcom-pdk2.rootfs.wic' to block device '/dev/sdx' using bmap file 'dh-image-demo-dh-imx8mp-dhcom-pdk2.rootfs.wic.bmap'
bmaptool: info: 100% copied
bmaptool: info: synchronizing '/dev/sdx'
bmaptool: info: copying time: 13.2s, copying speed 72.5 MiB/sec
```

It is equally possible to use plain `dd` to write the decompressed
system image into the block device as follows:
```
host$ dd if=dh-image-demo-dh-imx8mp-dhcom-pdk2.rootfs.wic \
         of=/dev/sdx bs=4M
```

This system uses GPT GUID Partition Table. It is highly recommended to
randomize GUIDs after writing system image to storage to avoid identical
PARTUUID for multiple partitions on different storage media in the system.
Identical PARTUUID for multiple partitions may lead to system using an
unexpected root device, which accidentally shares the same PARTUUID. To
randomize PARTUUID, use the following command:
```
host$ sgdisk -G /dev/sdx
```

Once the installation completed, insert the SD card into matching
slot on the device.

#### Operating system image installation into eMMC (from Linux)

Boot into the Linux operation system image and reach userspace. It is
mandatory that the system is booted from either microSD and specifically
not booted from eMMC.

To determine which block device is the eMMC, list block devices with
eMMC BOOT hardware partitions as follows:
```
$ ls -1 /dev/mmcblk*boot*
/dev/mmcblk2boot0
/dev/mmcblk2boot1
```
The listing above which implies the eMMC block device is `/dev/mmcblk2`.
This section assumes that the eMMC block device is recognized as a block
device `/dev/mmcblk2`.

Install system image into the block device. It is recommended to use
[bmaptool](https://github.com/yoctoproject/bmaptool) to expedite the
installation by skipping unused blocks. It is recommended to use up
to date bmaptool version at least 3.6.0 which supports decompression
of ZSTD compressed images, otherwise it is necessary to decompress the
ZSTD compressed images first, as follows:
```
host$ zstd -d dh-image-demo-dh-imx8mp-dhcom-pdk2.rootfs.wic.zst
```

To prevent any MBR or GPT contamination, it is recommended to erase
previous MBR and GPT partition tables:
```
host$ sgdisk -Z /dev/mmcblk2

host$ fdisk /dev/mmcblk2
Command (m for help): x                     # x to enter expert menu
Expert command (m for help): i              # i to change identifier
Enter the new disk identifier: 0x1234abcd   # pick random identifier
Expert command (m for help): r              # r to return to main menu
Command (m for help): w                     # w to write change to MBR
```

Use bmaptool to write system image into block device as follows:
```
host$ bmaptool copy --bmap \
    dh-image-demo-dh-imx8mp-dhcom-pdk2.rootfs.wic.bmap \
    dh-image-demo-dh-imx8mp-dhcom-pdk2.rootfs.wic.zst \
    /dev/mmcblk2
bmaptool: info: block map format version 2.0
bmaptool: info: 400474 blocks of size 4096 (1.5 GiB), mapped 246005 blocks (961.0 MiB or 61.4%)
bmaptool: info: copying image 'dh-image-demo-dh-imx8mp-dhcom-pdk2.rootfs.wic' to block device '/dev/mmcblk2' using bmap file 'dh-image-demo-dh-imx8mp-dhcom-pdk2.rootfs.wic.bmap'
bmaptool: info: 100% copied
bmaptool: info: synchronizing '/dev/mmcblk2'
bmaptool: info: copying time: 13.2s, copying speed 72.5 MiB/sec
```

It is equally possible to use plain `dd` to write the decompressed
system image into the block device as follows:
```
host$ dd if=dh-image-demo-dh-imx8mp-dhcom-pdk2.rootfs.wic \
         of=/dev/mmcblk2 bs=4M
```

This system uses GPT GUID Partition Table. It is highly recommended to
randomize GUIDs after writing system image to storage to avoid identical
PARTUUID for multiple partitions on different storage media in the system.
Identical PARTUUID for multiple partitions may lead to system using an
unexpected root device, which accidentally shares the same PARTUUID. To
randomize PARTUUID, use the following command:
```
host$ sgdisk -G /dev/mmcblk2
```

Once the installation completed, reboot the system and attempt to
boot from the eMMC.

## U-Boot bootloader installation

### U-Boot bootloader installation into SPI NOR

This section explains how to perform bootloader installation, update and
recovery. This section is only applicable in case it is desireable to
replace bootloader on the system.

The U-Boot bootloader is installed into SPI NOR. Installation into SPI NOR
is recommended to prevent accidental overwrite of the bootloader while the
system software in SD/eMMC is being replaced or updated. U-Boot bootloader
installation into SPI NOR can be performed from within U-Boot itself,
either using USB OTG DFU upload or from SD/eMMC card, or from running
Linux userspace.

The SPI NOR layout on this platform is as follows:
```
0x00_0000..0x00_0fff ... U-Boot FCFB
0x00_1000..0xfd_ffff ... U-Boot flash.bin
0xfe_0000..0xfe_ffff ... U-Boot environment (copy 1)
0xff_0000..0xff_ffff ... U-Boot environment (copy 2)
```

### U-Boot bootloader installation into SPI NOR (from U-Boot using USB OTG DFU upload)

This section depends on [dfu-util](https://dfu-util.sourceforge.net/) tool.
This tool must be installed on the host system.

Power on the system. Enter U-Boot console by pressing any key at prompt:
```
Hit any key to stop autoboot:
```

The system drops into U-Boot shell instantly. U-Boot shell on this system
looks as follows:
```
u-boot=>
```

Use the following command to start DFU on USB OTG port:
```
u-boot=> dfu 0 mtd
```

The system will now enumerate on the host PC as follows:
```
host$ dmesg -w
usb 5-2.2.2.1: new high-speed USB device number 21 using xhci_hcd
usb 5-2.2.2.1: New USB device found, idVendor=0483, idProduct=df11, bcdDevice= 2.00
usb 5-2.2.2.1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
usb 5-2.2.2.1: Product: USB download gadget
usb 5-2.2.2.1: Manufacturer: DH electronics
```

It is possible to list all DFU devices accessible to the host PC as follows:
```
host$ dfu-util -l
dfu-util 0.11

Copyright 2005-2009 Weston Schmidt, Harald Welte and OpenMoko Inc.
Copyright 2010-2021 Tormod Volden and Stefan Schmidt
This program is Free Software and has ABSOLUTELY NO WARRANTY
Please report bugs to http://sourceforge.net/p/dfu-util/tickets/

Found DFU: [0525:a4a5] ver=7e97, devnum=47, cfg=1, intf=0, path="5-2.2.2.3", alt=1, name="sf", serial="UNKNOWN"
Found DFU: [0525:a4a5] ver=7e97, devnum=47, cfg=1, intf=0, path="5-2.2.2.3", alt=0, name="ram", serial="UNKNOWN"
```

Install bootloader into SPI NOR using dfu-util as follows. The bootloader
consists of single combined file which contains both U-Boot SPL and U-Boot
uImage, `flash.bin`. The bootloader image `flash.bin` has to be prepended
with a FCFB header to be suitable for SPI NOR boot. A script is available
to perform this operation at [LINK](https://raw.githubusercontent.com/dh-electronics/meta-dhsom-imx-bsp/refs/heads/main/scripts/contrib/imx8mp-dhcom-mkfcfb.sh).
The resulting padded file is then sent to the board using `dfu-util`.

Create bootloader image with prepended FCFB header:
```
hostpc$ imx8mp-dhcom-mkfcfb.sh flash.bin flash-fcfb.bin
File "flash.bin" augmented with FCFB header as file "flash-fcfb.bin", write "flash-fcfb.bin" to FlexSPI NOR address 0x0
```

```
hostpc$ dfu-util -w -a 1 -D flash-fcfb.bin
dfu-util 0.11

Copyright 2005-2009 Weston Schmidt, Harald Welte and OpenMoko Inc.
Copyright 2010-2021 Tormod Volden and Stefan Schmidt
This program is Free Software and has ABSOLUTELY NO WARRANTY
Please report bugs to http://sourceforge.net/p/dfu-util/tickets/

dfu-util: Warning: Invalid DFU suffix signature
dfu-util: A valid DFU suffix will be required in a future dfu-util release
Waiting for device, exit with ctrl-C
Opening DFU capable USB device...
Device ID 0525:a4a5
Device DFU version 0110
Claiming USB DFU Interface...
Setting Alternate Interface #1 ...
Determining device status...
DFU state(2) = dfuIDLE, status(0) = No error condition is present
DFU mode device DFU version 0110
Device returned transfer size 4096
Copying data from PC to DFU device
Download        [=========================] 100%      1649720 bytes
Download done.
DFU state(7) = dfuMANIFEST, status(0) = No error condition is present
DFU state(2) = dfuIDLE, status(0) = No error condition is present
Done!
```

Once the installation completed, terminate DFU from U-Boot console
by pressing `Ctrl + C`, then reset the board.

```
u-boot=> dfu 0 mtd
################################################
################################################
################################################
################################################
#######################################DOWNLOAD ... OK
Ctrl+C to exit ...
u-boot=>
```

To reset the board, either press the `RESET` button on the board,
or perform reset from U-Boot shell as follows:

```
u-boot=> reset
```

Once the board resets, new U-Boot bootloader version will start.

### U-Boot bootloader installation into SPI NOR (from U-Boot from SD/eMMC card)

Power on the system. Enter U-Boot console by pressing any key at prompt:
```
Hit any key to stop autoboot:
```

The system drops into U-Boot shell instantly. U-Boot shell on this system
looks as follows:
```
u-boot=>
```

Use either of the following U-Boot scripts from update U-Boot in SPI NOR
from bootloader binaries located on either microSD card or eMMC card.

Read bootloader update from eMMC and write to SPI NOR:
```
u-boot=> run dh_update_emmc_to_sf
1645624 bytes read in 19 ms (82.6 MiB/s)
Base Address: 0x4ffff000
Base Address: 0x00000000
SF: Detected w25q128jw with page size 256 Bytes, erase size 4 KiB, total 16 MiB
device 0 offset 0x0, size 0x192c38
12288 bytes written, 1637432 bytes skipped in 0.163s, speed 10300690 B/s
```

Read bootloader update from microSD and write to SPI NOR:
```
u-boot=> run dh_update_sd_to_sf
1645624 bytes read in 17 ms (92.3 MiB/s)
Base Address: 0x4ffff000
Base Address: 0x00000000
SF: Detected w25q128jw with page size 256 Bytes, erase size 4 KiB, total 16 MiB
device 0 offset 0x0, size 0x192c38
12288 bytes written, 1637432 bytes skipped in 0.163s, speed 10300690 B/s
```

Note that the bootloader update removes old U-Boot environment. In case the
old environment contains any useful content, it is recommended to back up
that content at this point.

Once the installation completed, reset the board. To reset the board, either
press the `RESET` button on the board, or perform reset from U-Boot shell as
follows:

```
u-boot=> reset
```

### U-Boot bootloader installation into SPI NOR (from Linux)

It is possible to update the bootloader from a running Linux userspace.
The SPI NOR is exposed as single continuous MTD device by the Linux
kernel, therefore it is necessary to first assemble a suitable SPI NOR
image, and second write such an image to the MTD device.

To determine the MTD block device which represents the boot SPI NOR, iterate
over all of `/dev/mtdblock*` device nodes and select the one where the output
of `udevadm info /dev/mtdblockN` command matches the following output:

```
root@dh-imx8mp-dhcom-pdk2:~# udevadm info /dev/mtdblock0
P: /devices/platform/soc@0/30800000.bus/30bb0000.spi/spi_master/spi0/spi0.0/mtd/mtd0/mtdblock0
```

In case neither MTD block device hardware path matches the output above
for any of the `/dev/mtdblock*` device nodes, do not continue. Writing
data into another MTD block device may lead to data corruption or boot
failure.

In case a matching MTD block device node is found, write data into the
block device. Note that it is mandatory to use `/dev/mtdblockN` and not
use `/dev/mtdN` device, as the former is an emulated block device, while
the later is a control device which is only meant to be operated by the
mtd-utils.

The bootloader image `flash.bin` has to be prepended with a FCFB header
to be suitable for SPI NOR boot. A script is available to perform this
operation at [LINK](https://raw.githubusercontent.com/dh-electronics/meta-dhsom-imx-bsp/refs/heads/main/scripts/contrib/imx8mp-dhcom-mkfcfb.sh).
The resulting padded file is then written to the SPI NOR.

Create bootloader image with prepended FCFB header:
```
hostpc$ imx8mp-dhcom-mkfcfb.sh flash.bin flash-fcfb.bin
File "flash.bin" augmented with FCFB header as file "flash-fcfb.bin", write "flash-fcfb.bin" to FlexSPI NOR address 0x0
```

Use the following command to write U-Boot to SPI NOR:

```
root@dh-imx8mp-dhcom-pdk2:~# dd if=flash-fcfb.bin of=/dev/mtdblock0
3840+0 records in
3840+0 records out
1966080 bytes (2.0 MB, 1.9 MiB) copied, 17.7132 s, 111 kB/s
```

Once the installation completed, reset the board. To perform reset from
Linux kernel, use the following command:

```
root@dh-imx8mp-dhcom-pdk2:~# reboot
```

### U-Boot bootloader recovery (using USB SDPS upload)

This section depends on [dfu-util](https://dfu-util.sourceforge.net/) and
[uuu](https://github.com/NXPmicro/mfgtools.git) tools. These tools must be
installed on the host system.

In case the bootloader is damaged, malfunctioning or missing, it is still
possible to recover the system by starting a replacement bootloader using
USB SDPS upload.

Make sure the system is powered off and USB OTG cable is connected to port
`USB OTG` `X14`. Remove microSD card from the microSD card slot located on
SoM. Press and hold the button on the i.MX8M Plus DHCOM SoM that is located
at the edge of the SoM opposite to the slot connector, between microSD card
slot and eMMC chip, next to SPI NOR SOIC8 chip.

The system will now enumerate on the host PC as follows:
```
host$ dmesg -w
usb 5-2.2.2.3: new high-speed USB device number 50 using xhci_hcd
usb 5-2.2.2.3: New USB device found, idVendor=1fc9, idProduct=0146, bcdDevice= 0.02
usb 5-2.2.2.3: New USB device strings: Mfr=1, Product=2, SerialNumber=0
usb 5-2.2.2.3: Product: SE Blank 865
usb 5-2.2.2.3: Manufacturer: NXP       SemiConductor Inc
hid-generic 0003:1FC9:0146.000F: hiddev0,hidraw8: USB HID v1.10 Device [NXP       SemiConductor Inc  SE Blank 865  ] on usb-0000:47:00.1-2.2.2.3/input0
```

Release the button on SoM.

Use `uuu` to send U-Boot `flash.bin` binary using SDPS via USB OTG to the SoC:
This is used to start executing U-Boot:
```
host$ uuu -brun spl flash.bin
uuu (Universal Update Utility) for nxp imx chips -- lib1.5.233

Success 0    Failure 0


5:2223-1B1A2 1/ 1 [=================100%=================] SDPS[-t 10000]: boot -f flash.bin
```

The system will now disconnect from the host PC as follows:
```
host$ dmesg -w
usb 5-2.2.2.3: USB disconnect, device number 51
```

At this point, the uploaded U-Boot will start on the system and would
become accessible via serial console. Perform regular U-Boot bootloader
installation into SPI NOR procedure as documented above to recover the
system.

# Expansion module handling using Device Tree Overlays (DTO)

The capabilities of this system can be extended by attaching pluggable
expansion modules to various pin headers and connectors. For the Linux
kernel to recognize any such modules, those modules have to be described
in the Device Tree passed to the Linux kernel.

The system software implementation on this system uses Device Tree Overlays
(DTO) to describe expansion modules separately from the base Device Tree.
The base DT as well as DTOs are included in the Linux kernel fitImage and
applied by on top of the base DT by the U-Boot bootloader before booting
the Linux kernel. The combined DT with DTOs applied is then passed to the
Linux kernel. Which DTOs are applied is configurable by the user.

## Supported Device Tree Overlays

The following Device Tree Overlays are currently supported:

- DH 505-200 adapter card with Chefree CH101OLHLWH-002 LVDS display attached to it
  - `freescale_imx8mp-dhcom-pdk2-overlay-505-200-x12-ch101olhlwh.dtbo`
- DH 531-100 SPI/I2C board in header X21
  - `freescale_imx8mp-dhcom-pdk2-overlay-531-100-x21.dtbo`
- DH 531-200 SPI/I2C board in header X22
  - `freescale_imx8mp-dhcom-pdk2-overlay-531-100-x22.dtbo`
- DH 560-300 7" LCD board in header X12
  - `freescale_imx8mp-dhcom-pdk2-overlay-560-300-x12.dtbo`

The following Device Tree Overlays are automatically applied:

- DH i.MX8MP DHCOM SoM variant HI105/HI119 with 1x100/Full ethernet PHY
  - `freescale_imx8mp-dhcom-som-overlay-eth1xfast.dtbo`
- DH i.MX8MP DHCOM SoM variant HI106/HI120 with 2x100/Full ethernet PHY
  - `freescale_imx8mp-dhcom-som-overlay-eth2xfast.dtbo`
- DH i.MX8MP DHCOM PDK2 adjustments for HI106/HI120 with 2x100/Full ethernet PHY
  - `freescale_imx8mp-dhcom-pdk-overlay-eth2xfast.dtbo`
- DH i.MX8MP DHCOM SoM rev.100 variant HI104/HI105/HI106
  - `freescale_imx8mp-dhcom-som-overlay-rev100.dtbo`
- DH i.MX8MP DHCOM PDK2 adjustments for rev.100 SoM variant HI104/HI105/HI106
  - `freescale_imx8mp-dhcom-pdk2-overlay-rev100.dtbo`

## List available Device Tree Overlays (from U-Boot)

To list Device Tree Overlays supported by the current operating system image,
inspect the Linux kernel fitImage from within U-Boot as follows.

First, load the kernel fitImage from SD or eMMC into memory:
```
u-boot=> load mmc 0:1 ${loadaddr} boot/fitImage
5965452 bytes read in 250 ms (22.8 MiB/s)
```

Second, list the available fitImage configurations, which also
match the available base Device Tree and Device Tree Overlays:
```
u-boot=> iminfo $loadaddr

## Checking Image at 50000000 ...
   FIT image found
   FIT description: Kernel fitImage for DH Linux Distribution/6.12.56+git/dh-imx8mp-dhcom-pdk2
   Created:         2025-10-29  13:09:02 UTC
    Image 0 (kernel-1)
     Description:  Linux kernel
     Created:      2025-10-29  13:09:02 UTC
     Type:         Kernel Image
     Compression:  gzip compressed
     Data Start:   0x500000fc
     Data Size:    10915008 Bytes = 10.4 MiB
     Architecture: AArch64
     OS:           Linux
     Load Address: 0x40200000
     Entry Point:  0x40200000
     Hash algo:    sha256
     Hash value:   688507820dacf19419c080288ec92647b2e4cbb07e06a040c397700e1b0072fa
    Image 1 (fdt-freescale_imx8mp-dhcom-pdk2.dtb)
     Description:  Flattened Device Tree blob
     Created:      2025-10-29  13:09:02 UTC
     Type:         Flat Device Tree
     Compression:  uncompressed
     Data Start:   0x50a68edc
     Data Size:    81657 Bytes = 79.7 KiB
     Architecture: AArch64
     Load Address: 0x5c000000
     Hash algo:    sha256
     Hash value:   50733981c79ce02e2397eb42fbbe386f1aaa2ef14e94b17f36b7f4aeba05be57
    Image 2 (fdt-freescale_imx8mp-dhcom-som-overlay-eth1xfast.dtbo)
     Description:  Flattened Device Tree blob
     Created:      2025-10-29  13:09:02 UTC
     Type:         Flat Device Tree
     Compression:  uncompressed
     Data Start:   0x50a7cee8
     Data Size:    2560 Bytes = 2.5 KiB
     Architecture: AArch64
     Load Address: 0x5c080000
     Hash algo:    sha256
     Hash value:   516137f2d5de7b77e31c521089280d401db08d6584a7a779697f1e067f33914a
    Image 3 (fdt-freescale_imx8mp-dhcom-som-overlay-eth2xfast.dtbo)
     Description:  Flattened Device Tree blob
     Created:      2025-10-29  13:09:02 UTC
     Type:         Flat Device Tree
     Compression:  uncompressed
     Data Start:   0x50a7d9f8
     Data Size:    3355 Bytes = 3.3 KiB
     Architecture: AArch64
     Load Address: 0x5c080000
     Hash algo:    sha256
     Hash value:   a724dcd9ef549de2d11e4799b9e7473b388da0b8a44ed0c05f872c660b0164da
    Image 4 (fdt-freescale_imx8mp-dhcom-pdk-overlay-eth2xfast.dtbo)
     Description:  Flattened Device Tree blob
     Created:      2025-10-29  13:09:02 UTC
     Type:         Flat Device Tree
     Compression:  uncompressed
     Data Start:   0x50a7e824
     Data Size:    232 Bytes = 232 Bytes
     Architecture: AArch64
     Load Address: 0x5c080000
     Hash algo:    sha256
     Hash value:   7e8629124e8ce03d901574060b6d7fc79609641a53122cbe341fd156614beaae
    Image 5 (fdt-freescale_imx8mp-dhcom-som-overlay-rev100.dtbo)
     Description:  Flattened Device Tree blob
     Created:      2025-10-29  13:09:02 UTC
     Type:         Flat Device Tree
     Compression:  uncompressed
     Data Start:   0x50a7ea18
     Data Size:    5394 Bytes = 5.3 KiB
     Architecture: AArch64
     Load Address: 0x5c080000
     Hash algo:    sha256
     Hash value:   8c099fede7f58f713a27e8388d9abf1bc5b3cb36d20c4468f47cd2deae6ef823
    Image 6 (fdt-freescale_imx8mp-dhcom-pdk2-overlay-531-100-x21.dtbo)
     Description:  Flattened Device Tree blob
     Created:      2025-10-29  13:09:02 UTC
     Type:         Flat Device Tree
     Compression:  uncompressed
     Data Start:   0x50a80040
     Data Size:    715 Bytes = 715 Bytes
     Architecture: AArch64
     Load Address: 0x5c080000
     Hash algo:    sha256
     Hash value:   ebc223261b230d9bef576c05b39482350096724cfaab64af578349ea0d540100
    Image 7 (fdt-freescale_imx8mp-dhcom-pdk2-overlay-531-100-x22.dtbo)
     Description:  Flattened Device Tree blob
     Created:      2025-10-29  13:09:02 UTC
     Type:         Flat Device Tree
     Compression:  uncompressed
     Data Start:   0x50a80420
     Data Size:    715 Bytes = 715 Bytes
     Architecture: AArch64
     Load Address: 0x5c080000
     Hash algo:    sha256
     Hash value:   c30f27a03292b9f889a97c508f685bb63de254534bbcd07fbb8ed16a6a6d2a24
    Image 8 (fdt-freescale_imx8mp-dhcom-pdk2-overlay-505-200-x12-ch101olhlwh.dtbo)
     Description:  Flattened Device Tree blob
     Created:      2025-10-29  13:09:02 UTC
     Type:         Flat Device Tree
     Compression:  uncompressed
     Data Start:   0x50a8080c
     Data Size:    3959 Bytes = 3.9 KiB
     Architecture: AArch64
     Load Address: 0x5c080000
     Hash algo:    sha256
     Hash value:   e7b92210a4618a52ad7948d4ae611d09a43c753b5d05891897bed8a40a6c5e56
    Image 9 (fdt-freescale_imx8mp-dhcom-pdk2-overlay-560-300-x12.dtbo)
     Description:  Flattened Device Tree blob
     Created:      2025-10-29  13:09:02 UTC
     Type:         Flat Device Tree
     Compression:  uncompressed
     Data Start:   0x50a81898
     Data Size:    3977 Bytes = 3.9 KiB
     Architecture: AArch64
     Load Address: 0x5c080000
     Hash algo:    sha256
     Hash value:   7dbe54e8f44987a0b42e2845afcda7096a9aecad569376299c095f411f26b7ea
    Image 10 (fdt-freescale_imx8mp-dhcom-pdk2-overlay-rev100.dtbo)
     Description:  Flattened Device Tree blob
     Created:      2025-10-29  13:09:02 UTC
     Type:         Flat Device Tree
     Compression:  uncompressed
     Data Start:   0x50a82930
     Data Size:    643 Bytes = 643 Bytes
     Architecture: AArch64
     Load Address: 0x5c080000
     Hash algo:    sha256
     Hash value:   3e6c143a4d5af13c7bc474e341eb089cd796cb5829a195c5de146e5785534737
    Default Configuration: 'conf-freescale_imx8mp-dhcom-pdk2.dtb'
    Configuration 0 (conf-freescale_imx8mp-dhcom-pdk2.dtb)
     Description:  1 Linux kernel, FDT blob
     Kernel:       kernel-1
     FDT:          fdt-freescale_imx8mp-dhcom-pdk2.dtb
     Hash algo:    sha256
     Hash value:   unavailable
    Configuration 1 (conf-freescale_imx8mp-dhcom-som-overlay-eth1xfast.dtbo)
     Description:  0 FDT blob
     Kernel:       unavailable
     FDT:          fdt-freescale_imx8mp-dhcom-som-overlay-eth1xfast.dtbo
     Hash algo:    sha256
     Hash value:   unavailable
    Configuration 2 (conf-freescale_imx8mp-dhcom-som-overlay-eth2xfast.dtbo)
     Description:  0 FDT blob
     Kernel:       unavailable
     FDT:          fdt-freescale_imx8mp-dhcom-som-overlay-eth2xfast.dtbo
     Hash algo:    sha256
     Hash value:   unavailable
    Configuration 3 (conf-freescale_imx8mp-dhcom-pdk-overlay-eth2xfast.dtbo)
     Description:  0 FDT blob
     Kernel:       unavailable
     FDT:          fdt-freescale_imx8mp-dhcom-pdk-overlay-eth2xfast.dtbo
     Hash algo:    sha256
     Hash value:   unavailable
    Configuration 4 (conf-freescale_imx8mp-dhcom-som-overlay-rev100.dtbo)
     Description:  0 FDT blob
     Kernel:       unavailable
     FDT:          fdt-freescale_imx8mp-dhcom-som-overlay-rev100.dtbo
     Hash algo:    sha256
     Hash value:   unavailable
    Configuration 5 (conf-freescale_imx8mp-dhcom-pdk2-overlay-531-100-x21.dtbo)
     Description:  0 FDT blob
     Kernel:       unavailable
     FDT:          fdt-freescale_imx8mp-dhcom-pdk2-overlay-531-100-x21.dtbo
     Hash algo:    sha256
     Hash value:   unavailable
    Configuration 6 (conf-freescale_imx8mp-dhcom-pdk2-overlay-531-100-x22.dtbo)
     Description:  0 FDT blob
     Kernel:       unavailable
     FDT:          fdt-freescale_imx8mp-dhcom-pdk2-overlay-531-100-x22.dtbo
     Hash algo:    sha256
     Hash value:   unavailable
    Configuration 7 (conf-freescale_imx8mp-dhcom-pdk2-overlay-505-200-x12-ch101olhlwh.dtbo)
     Description:  0 FDT blob
     Kernel:       unavailable
     FDT:          fdt-freescale_imx8mp-dhcom-pdk2-overlay-505-200-x12-ch101olhlwh.dtbo
     Hash algo:    sha256
     Hash value:   unavailable
    Configuration 8 (conf-freescale_imx8mp-dhcom-pdk2-overlay-560-300-x12.dtbo)
     Description:  0 FDT blob
     Kernel:       unavailable
     FDT:          fdt-freescale_imx8mp-dhcom-pdk2-overlay-560-300-x12.dtbo
     Hash algo:    sha256
     Hash value:   unavailable
    Configuration 9 (conf-freescale_imx8mp-dhcom-pdk2-overlay-rev100.dtbo)
     Description:  0 FDT blob
     Kernel:       unavailable
     FDT:          fdt-freescale_imx8mp-dhcom-pdk2-overlay-rev100.dtbo
     Hash algo:    sha256
     Hash value:   unavailable
## Checking hash(es) for FIT Image at 50000000 ...
   Hash(es) for Image 0 (kernel-1): sha256+
   Hash(es) for Image 1 (fdt-freescale_imx8mp-dhcom-pdk2.dtb): sha256+
   Hash(es) for Image 2 (fdt-freescale_imx8mp-dhcom-som-overlay-eth1xfast.dtbo): sha256+
   Hash(es) for Image 3 (fdt-freescale_imx8mp-dhcom-som-overlay-eth2xfast.dtbo): sha256+
   Hash(es) for Image 4 (fdt-freescale_imx8mp-dhcom-pdk-overlay-eth2xfast.dtbo): sha256+
   Hash(es) for Image 5 (fdt-freescale_imx8mp-dhcom-som-overlay-rev100.dtbo): sha256+
   Hash(es) for Image 6 (fdt-freescale_imx8mp-dhcom-pdk2-overlay-531-100-x21.dtbo): sha256+
   Hash(es) for Image 7 (fdt-freescale_imx8mp-dhcom-pdk2-overlay-531-100-x22.dtbo): sha256+
   Hash(es) for Image 8 (fdt-freescale_imx8mp-dhcom-pdk2-overlay-505-200-x12-ch101olhlwh.dtbo): sha256+
   Hash(es) for Image 9 (fdt-freescale_imx8mp-dhcom-pdk2-overlay-560-300-x12.dtbo): sha256+
   Hash(es) for Image 10 (fdt-freescale_imx8mp-dhcom-pdk2-overlay-rev100.dtbo): sha256+
```

The Device Tree and Device Tree Overlays lists below are based on fitImage
configuration listing printed in the example above, with the `conf-` prefix
removed.

The listing contains one base Device Tree:

- `freescale_imx8mp-dhcom-pdk2.dtb`

The listing contains the following Device Tree Overlays:

- `freescale_imx8mp-dhcom-pdk2-overlay-505-200-x12-ch101olhlwh.dtbo`
- `freescale_imx8mp-dhcom-pdk2-overlay-531-100-x21.dtbo`
- `freescale_imx8mp-dhcom-pdk2-overlay-531-100-x22.dtbo`
- `freescale_imx8mp-dhcom-pdk2-overlay-560-300-x12.dtbo`
- `freescale_imx8mp-dhcom-som-overlay-eth1xfast.dtbo`
- `freescale_imx8mp-dhcom-som-overlay-eth2xfast.dtbo`
- `freescale_imx8mp-dhcom-pdk-overlay-eth2xfast.dtbo`
- `freescale_imx8mp-dhcom-som-overlay-rev100.dtbo`
- `freescale_imx8mp-dhcom-pdk2-overlay-rev100.dtbo`

## Select Device Tree Overlays applied on top of Linux DT (from U-Boot)

The application of additional Device Tree Overlays available in the Linux
kernel fitImage on top of a base Device Tree is governed by the `loaddtos`
U-Boot environment variable.

The `loaddtos` U-Boot environment variable refers to configurations
available in the Linux kernel fitImage. Those configurations refer
to Device Tree or Device Tree Overlays embedded in the fitImage. The
`loaddtos` environment variable must list one base Device Tree and
zero or more additional Device Tree Overlays which are to be applied
on top of the base Device Tree. Entries listed in the `loaddtos`
environment variable must each be prefixed by the `#` character.

To configure the system to use `freescale_imx8mp-dhcom-pdk2.dtb` base Device
Tree and apply additional `freescale_imx8mp-dhcom-pdk2-overlay-560-300-x12.dtbo`
Device Tree Overlay, configure the `loaddtos` environment variable as
follows:
```
                     .------------------------------------.----- '#' Separator
                     |                                    |
                     v                                    v
=> env set loaddtos '#conf-freescale_imx8mp-dhcom-pdk2.dtb#conf-freescale_imx8mp-dhcom-pdk2-overlay-560-300-x12.dtbo'
                       ^                                    ^
                       |                                    |
                       |                                    '--- 560-300 display DTO
                       |
                       '---------------------------------------- Base Device Tree
```

To make configuration persistent, store U-Boot environment:
```
=> env save
```

To boot the system with additional DTO applied:
```
u-boot=> env set loaddtos '#conf-freescale_imx8mp-dhcom-pdk2.dtb#conf-freescale_imx8mp-dhcom-pdk2-overlay-560-300-x12.dtbo'
u-boot=> boot
switch to partitions #0, OK
mmc0 is current device
Scanning mmc 0:1...
Found U-Boot script /boot/boot.scr
6667 bytes read in 1 ms (6.4 MiB/s)
## Executing script at 50000000
11024068 bytes read in 116 ms (90.6 MiB/s)
Using base DT fdt-freescale_imx8mp-dhcom-pdk2.dtb
## Copying 'fdt-freescale_imx8mp-dhcom-pdk2.dtb' subimage from FIT image at 50000000 ...
sha256+    Loading part 253 ... OK
Working FDT set to 5c000000
Applying DTO fdt-freescale_imx8mp-dhcom-pdk2-overlay-560-300-x12.dtbo
## Copying 'fdt-freescale_imx8mp-dhcom-pdk2-overlay-560-300-x12.dtbo' subimage from FIT image at 50000000 ...
sha256+    Loading part 253 ... OK
Notice: a /chosen/kaslr-seed is automatically added to the device-tree when booted via booti/bootm/bootz therefore usin
g this command is likely no longer needed
Booting the Linux kernel...
## Loading kernel (any) from FIT Image at 50000000 ...
   Using 'conf-freescale_imx8mp-dhcom-pdk2.dtb' configuration
   Trying 'kernel-1' kernel subimage
     Description:  Linux kernel
     Created:      2025-10-29  13:09:02 UTC
     Type:         Kernel Image
     Compression:  gzip compressed
     Data Start:   0x500000fc
     Data Size:    10915008 Bytes = 10.4 MiB
     Architecture: AArch64
     OS:           Linux
     Load Address: 0x40200000
     Entry Point:  0x40200000
     Hash algo:    sha256
     Hash value:   688507820dacf19419c080288ec92647b2e4cbb07e06a040c397700e1b0072fa
   Verifying Hash Integrity ... sha256+ OK
## Flattened Device Tree blob at 5c000000
   Booting using the fdt blob at 0x5c000000
Working FDT set to 5c000000
   Uncompressing Kernel Image to 40200000
   Loading Device Tree to 00000000fde54000, end 00000000fdeaafff ... OK
Working FDT set to fde54000

Starting kernel ...
```

# IO access

This section describe access to various IO of this system.

## Serial ports and UARTs

U-Boot on this system provides serial console access via `RS232 UART1`
DB9 plug `X8`, this is `serial@30860000`. Other serial ports can be
made available by modifying U-Boot control Device Tree.

Linux on this system provides serial console access via `RS232 UART1`
DB9 plug `X8`, this is `30860000.serial`. Linux also provides two
additional serial ports accessible via pin header `UART2 TTL` `X6`
`30880000.serial` and `UART3 TTL` `X7` `30a60000.serial` . These ports
are accessible via `/dev/ttymxc*` device nodes. To discern the ports
apart, use `udevadm info /dev/ttymxc*` command, which prints the full
hardware path to the selected port:
```
root@dh-imx8mp-dhcom-pdk2:~# udevadm info /dev/ttymxc*
P: /devices/platform/soc@0/30800000.bus/30800000.spba-bus/30860000.serial/30860000.serial:0/30860000.serial:0.0/tty/ttymxc0
                                                          ^^^^^^^^^^^^^^^
M: ttymxc0
   ^^^^^^^
```

To access either serial port, use suitable terminate emulator,
for example `minicom`, `picocom`, `screen`, and many others.

## IO

### Buttons

U-Boot on this system provides access to four buttons via plain GPIOs.
Use the following `gpio input` command to sample button states. Note
that `gpio input` command sets return value according to the GPIO
state, which can be used in conditional statements:

```
u-boot=> gpio input GPIO1_9
gpio: pin GPIO1_9 (gpio 9) value is 1
u-boot=> echo $?
1

u-boot=> gpio input GPIO1_9
gpio: pin GPIO1_9 (gpio 9) value is 0
u-boot=> echo $?
0
```

Linux on this system provides access to four buttons via input event
device, using `gpio-keys` driver. To access GPIO keys on this platform,
open the matching `/dev/input/event*` event device.

Example using `evtest` tool:

```
root@dh-imx8mp-dhcom-pdk2:~# evtest

No device specified, trying to scan all of /dev/input/event*
Available devices:
/dev/input/event0:      TSC200X touchscreen
/dev/input/event1:      gpio-keys
Select the device event number [0-1]: 1
Input driver version is 1.0.1
Input device ID: bus 0x19 vendor 0x1 product 0x1 version 0x100
Input device name: "gpio-keys"
Supported events:
  Event type 0 (EV_SYN)
  Event type 1 (EV_KEY)
    Event code 30 (KEY_A)
    Event code 32 (KEY_D)
    Event code 46 (KEY_C)
    Event code 48 (KEY_B)
Properties:
Testing ... (interrupt to exit)
Event: time 1762221597.450323, type 1 (EV_KEY), code 30 (KEY_A), value 1
Event: time 1762221597.450323, -------------- SYN_REPORT ------------
Event: time 1762221597.564612, type 1 (EV_KEY), code 30 (KEY_A), value 0
Event: time 1762221597.564612, -------------- SYN_REPORT ------------
Event: time 1762221597.827719, type 1 (EV_KEY), code 48 (KEY_B), value 1
Event: time 1762221597.827719, -------------- SYN_REPORT ------------
Event: time 1762221597.948391, type 1 (EV_KEY), code 48 (KEY_B), value 0
Event: time 1762221597.948391, -------------- SYN_REPORT ------------
Event: time 1762221598.177887, type 1 (EV_KEY), code 46 (KEY_C), value 1
Event: time 1762221598.177887, -------------- SYN_REPORT ------------
Event: time 1762221598.302191, type 1 (EV_KEY), code 46 (KEY_C), value 0
Event: time 1762221598.302191, -------------- SYN_REPORT ------------
Event: time 1762221598.530688, type 1 (EV_KEY), code 32 (KEY_D), value 1
Event: time 1762221598.530688, -------------- SYN_REPORT ------------
Event: time 1762221598.634053, type 1 (EV_KEY), code 32 (KEY_D), value 0
Event: time 1762221598.634053, -------------- SYN_REPORT ------------
```

### LEDs

U-Boot on this system provides access to four LEDs via `led` command.

To list available LEDs and their current state, use the `led list` command:
```
u-boot=> led list
green:indicator-0      off
green:indicator-1      off
green:indicator-2      off
green:indicator-3      off
```

To enable an LED, use `led <led_label> on` command:
```
u-boot=> led green:indicator-0 on
u-boot=> led green:indicator-1 on
u-boot=> led green:indicator-2 on
u-boot=> led green:indicator-3 on
```

To disable an LED, use `led <led_label> off` command:
```
u-boot=> led green:indicator-0 off
u-boot=> led green:indicator-1 off
u-boot=> led green:indicator-2 off
u-boot=> led green:indicator-3 off
```

Linux on this system provides access to three LEDs via sysfs LED API,
LED-5 is DH GPIO-E used as touch controller interrupt, and therefore
unavailable to LED subsystem in Linux.

To enable an LED, write 1 into matching sysfs LED attribute:
```
root@dh-imx8mp-dhcom-pdk2:~# echo 1 > /sys/class/leds/green\:indicator/brightness
root@dh-imx8mp-dhcom-pdk2:~# echo 1 > /sys/class/leds/green\:indicator_1/brightness
root@dh-imx8mp-dhcom-pdk2:~# echo 1 > /sys/class/leds/green\:indicator_2/brightness
```

To disable an LED, write 0 into matching sysfs LED attribute:
```
root@dh-imx8mp-dhcom-pdk2:~# echo 0 > /sys/class/leds/green\:indicator/brightness
root@dh-imx8mp-dhcom-pdk2:~# echo 0 > /sys/class/leds/green\:indicator_1/brightness
root@dh-imx8mp-dhcom-pdk2:~# echo 0 > /sys/class/leds/green\:indicator_2/brightness
```

### GPIOs

U-Boot on this system provides access to multiple GPIO pins.

To list GPIOs and their current state, use the `gpio status` command:
```
u-boot=> gpio status
Bank GPIO1_:
GPIO1_5: output: 0 [x] led-3.gpios
GPIO1_11: output: 0 [x] led-2.gpios

Bank GPIO2_:
GPIO2_10: output: 0 [x] regulator-eth-vio.gpio
GPIO2_12: input: 0 [x] mmc@30b50000.cd-gpios

Bank GPIO3_:
GPIO3_20: output: 1 [x] ethernet-phy@1.reset-gpios

Bank GPIO4_:
GPIO4_2: output: 1 [x] ethernet-phy@2.reset-gpios

Bank GPIO5_:
GPIO5_18: output: 0 [x] i2c@30a40000.scl-gpios
GPIO5_19: output: 0 [x] i2c@30a40000.sda-gpios
GPIO5_22: output: 0 [x] led-0.gpios
GPIO5_23: output: 0 [x] led-1.gpios
```

To set a GPIO as Output-High, use `gpio set <pin>` command:
```
u-boot=> gpio set GPIO5_22
gpio: pin GPIO5_22 (gpio 150) value is 1
```

To set a GPIO as Output-Low, use `gpio clear <pin>` command:
```
u-boot=> gpio clear GPIO5_22
gpio: pin GPIO5_22 (gpio 150) value is 0
```

To toggle a GPIO, use `gpio toggle <pin>` command:
```
u-boot=> gpio toggle GPIO5_22
gpio: pin GPIO5_22 (gpio 150) value is 1
u-boot=> gpio toggle GPIO5_22
gpio: pin GPIO5_22 (gpio 150) value is 0
```

Linux on this system provides access to multiple GPIO pins. Access to
GPIOs is provided using GPIO chardev interface and libgpiod. Subset of
GPIO lines is named, which makes them easier to discern in libgpiod
tools output.

To list available GPIOs, use the `gpioinfo` command:
```
root@dh-imx8mp-dhcom-pdk2:~# gpioinfo
gpiochip0 - 32 lines:
        line   0:       "DHCOM-G"               output consumer="enable"
        line   1:       unnamed                 input
        line   2:       unnamed                 input
        line   3:       unnamed                 input
        line   4:       unnamed                 input
        line   5:       "DHCOM-I"               output consumer="green:indicator_2"
        line   6:       "DHCOM-J"               output active-low consumer="PCIe reset"
        line   7:       "DHCOM-L"               input
        line   8:       "DHCOM-B"               input active-low consumer="TA2-GPIO-B"
        line   9:       "DHCOM-A"               input active-low consumer="TA1-GPIO-A"
...
gpiochip1 - 32 lines:
        line   0:       unnamed                 input
        line   1:       unnamed                 input
...
        line  11:       "DHCOM-K"               input
...
```

To get current state of a GPIO, use the `gpioget` command:
```
root@dh-imx8mp-dhcom-pdk2:~# gpioget -c /dev/gpiochip1 11
"11"=inactive
...
```

To set a GPIO as Output-High, use `gpioset ... <line>=1` command:
```
root@dh-imx8mp-dhcom-pdk2:~# gpioset -c /dev/gpiochip1 11=1
```

To set a GPIO as Output-Low, use `gpioset ... <line>=0` command:
```
root@dh-imx8mp-dhcom-pdk2:~# gpioset -c /dev/gpiochip1 11=0
```

It is possible to refer to GPIOs using symbolic names:
```
# Numerical reference to GPIO on gpiochip1 line 11:
root@dh-imx8mp-dhcom-pdk2:~# gpioget -c /dev/gpiochip1 11
"11"=inactive

# Symbolic name reference to GPIO on gpiochip1 line 11:
root@dh-imx8mp-dhcom-pdk2:~# gpioget DHCOM-K
"DHCOM-K"=inactive
```

Note that once the `gpioset` command exits, the line returns to undefined state.

## Storage

### MicroSD

U-Boot on this system provides access to microSD card via standard MMC and
block device interface. To detect and print information about the microSD
card, use `mmc dev` and `mmc info` commands. The microSD card is MMC device
number 0:
```
u-boot=> mmc dev 0
switch to partitions #0, OK
mmc0 is current device

u-boot=> mmc info
Device: FSL_SDHC
Manufacturer ID: ad
OEM: 4c53
Name: USD00
Bus Speed: 50000000
Mode: SD High Speed (50MHz)
Rd Block Len: 512
SD version 3.0
High Capacity: Yes
Capacity: 58.9 GiB
Bus Width: 4-bit
Erase Group Size: 512 Bytes
```

Access to filesystem is available using U-Boot generic filesystem interface commands:
```
u-boot=> mmc part

Partition Map for mmc device 1  --   Partition Type: DOS

Part    Start Sector    Num Sectors     UUID            Type
  1     8192            3200994         076c4a2a-01     83 Boot
...

u-boot=> ls mmc 0:1
            ./
            ../
            lost+found/
    <SYM>   bin
            boot/
...
```

Linux on this system provides access to microSD card via standard block device
interface. It is recommended to use deterministic device name symlink generated
by `udev` to access block devices. The microSD card block device is accessible
via the following deterministic device name symlink:
```
/dev/disk/by-path/platform-30b50000.mmc
```

In case the deterministic device name symlink is not available, it is possible
to resolve microSD card block device to `/dev/mmcblk*` device node manually by
reading out the character device major and minor numbers from sysfs, and then
by performing look up in the `/dev/` directory, using the following commands.
In the example below, major and minor numbers for microSD card are 179 and 96,
which are represented by device node `/dev/mmcblk1`:
```
root@dh-imx8mp-dhcom-pdk2:~# cat /sys/devices/platform/soc\@0/30800000.bus/30b50000.mmc/mmc_host/mmc*/mmc*/block/mmcblk*/dev
179:96
^^^ ^^

root@dh-imx8mp-dhcom-pdk2:~# ls -la /dev/mmcblk*
...
brw-rw---- 1 root disk 179, 96 Mar 10 03:53 /dev/mmcblk1
                       ^^^  ^^              ^^^^^^^^^^^^
...
```

### eMMC

U-Boot on this system provides access to eMMC card via standard MMC and
block device interface. To detect and print information about the eMMC
card, use `mmc dev` and `mmc info` commands. The eMMC card is MMC device
number 1:
```
u-boot=> mmc dev 1
switch to partitions #0, OK
mmc1(part 0) is current device

u-boot=> mmc info
Device: FSL_SDHC
Manufacturer ID: 45
OEM: 0
Name: DG4016
Bus Speed: 100000000
Mode: HS400ES (200MHz)
Rd Block Len: 512
MMC version 5.1
High Capacity: Yes
Capacity: 14.7 GiB
Bus Width: 8-bit DDR
Erase Group Size: 512 KiB
HC WP Group Size: 8 MiB
User Capacity: 14.7 GiB WRREL
Boot Capacity: 4 MiB ENH
RPMB Capacity: 4 MiB ENH
Boot area 0 is not write protected
Boot area 1 is not write protected
```

Access to filesystem is available using U-Boot generic filesystem interface commands:
```
u-boot=> mmc part

Partition Map for mmc device 1  --   Partition Type: DOS

Part    Start Sector    Num Sectors     UUID            Type
  1     8192            3200994         076c4a2a-01     83 Boot
...

u-boot=> ls mmc 1:1
            ./
            ../
            lost+found/
    <SYM>   bin
            boot/
...
```

Linux on this system provides access to eMMC card via standard block device
interface. It is recommended to use deterministic device name symlink generated
by `udev` to access block devices. The eMMC card block device is accessible
via the following deterministic device name symlink:
```
/dev/disk/by-path/platform-30b60000.mmc
```

In case the deterministic device name symlink is not available, it is possible
to resolve eMMC card block device to `/dev/mmcblk*` device node manually by
reading out the character device major and minor numbers from sysfs, and then
by performing look up in the `/dev/` directory, using the following commands.
In the example below, major and minor numbers for eMMC card are 179 and 0,
which are represented by device node `/dev/mmcblk2`:
```
root@dh-imx8mp-dhcom-pdk2:~# cat /sys/devices/platform/soc\@0/30800000.bus/30b60000.mmc/mmc_host/mmc*/mmc*/block/mmcblk*/dev
179:0
^^^ ^

root@dh-imx8mp-dhcom-pdk2:~# ls -la /dev/mmcblk*
...
brw-rw---- 1 root disk 179,  0 Mar 10 03:53 /dev/mmcblk2
                       ^^^   ^              ^^^^^^^^^^^^
...
```

## Network

### Ethernet

U-Boot on this system provides access to two ethernet interfaces via U-Boot
networking stack. Use `net list` command to list available ethernet interfaces:
```
u-boot=> net list
eth1 : ethernet@30be0000 00:11:22:33:44:55
eth0 : ethernet@30bf0000 00:11:22:33:44:56 active

```

To select active ethernet interface, set U-Boot environment variable `ethact`.

Linux on this system provides access to two ethernet interfaces via Linux
networking stack. These interfaces are assigned deterministic interface
names via systemd udevd rules.

```
root@dh-imx8mp-dhcom-pdk2:~# ip addr show
...
4: ethsom0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 ...
5: ethsom1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 ...
...
```

To discern the ports apart, use `udevadm info /sys/class/net/ethsom*` command,
which prints the full hardware path to the selected ethernet interface. The
default assignment `30bf0000.ethernet` is on-SoC EQoS/DWMAC ethernet, and
`30be0000.ethernet` is on-SoC FEC ethernet:

```
root@dh-imx8mp-dhcom-pdk2:~# udevadm info /sys/class/net/ethsom0
P: /devices/platform/soc@0/30800000.bus/30bf0000.ethernet/net/ethsom0
M: ethsom0
...

root@dh-imx8mp-dhcom-pdk2:~# udevadm info /sys/class/net/ethsom1
P: /devices/platform/soc@0/30800000.bus/30be0000.ethernet/net/ethsom1
M: ethsom1
...
```

### WiFi and Bluetooth

Linux on this system provides access to WiFi interface via Linux networking
stack. This interface is assigned deterministic interface name via systemd
udevd rules.

```
root@dh-imx8mp-dhcom-pdk2:~# udevadm info /sys/class/net/wlansom0
P: /devices/platform/soc@0/30800000.bus/30b40000.mmc/mmc_host/mmc0/mmc0:0001/mmc0:0001:1/net/wlansom0
M: wlansom0
...
```

To operate the WiFi interface, use `iw` and `wpa-supplicant` tools, or any
other suitable network management tooling. Example scan for nearby networks:

```
root@dh-imx8mp-dhcom-pdk2:~# ip link set wlansom0 up
root@dh-imx8mp-dhcom-pdk2:~# iw dev wlansom0 scan
BSS 00:11:22:33:44:55(on wlansom0)
...
```

Linux on this system provides access to Bluetooth interface via Linux bluetooth
stack. To operate the Bluetooth interface, use the Bluez stack, for example via
the `bluetoothctl` command:

```
root@dh-imx8mp-dhcom-pdk2:~# bluetoothctl
hci0 new_settings: powered bondable ssp br/edr le secure-conn
Agent registered
[CHG] Controller 10:98:00:11:22:33 Pairable: yes
[bluetooth]# power on
Changing power on succeeded
[bluetooth]# scan on
SetDiscoveryFilter success
hci0 type 7 discovering on
Discovery started
[CHG] Controller 10:98:00:11:22:33 Discovering: yes
...
```

### CAN

Linux on this system provides access to CAN/CANFD interface via Linux networking
stack and socketcan interface.

To bring the CAN interface up in FD mode, 125 kbps bitrate, 250 kbps data rate,
use the following command:

```
$ ip link set can0 up type can bitrate 125000 dbitrate 250000 fd on
```

To bring the CAN interface up in classic mode, 125 kbps bitrate,
use the following command:

```
$ ip link set can0 up type can bitrate 125000 fd off
```

To bring the CAN interface down, use the following command:

```
$ ip link set can0 down
```

Use suitable socketcan tools to communicate via CAN, for example `candump`,
`cansend`, `cangen`.

## USB

### USB Host

This system provides one USB host port connected to a USB 2.0 hub located
on the carrier board. Access to the USB hub ports is possible via stacked
USB connector `X13`.

This system provides one USB OTG port connected to a mini-USB connector `X14`.

U-Boot on this system provides access to USB host and peripheral ports via
standard U-Boot USB stack. To enumerate USB devices attached to the host
port, use `usb` command:

```
u-boot=> usb reset
resetting USB...
Register 2000140 NbrPorts 2
Starting the controller
USB XHCI 1.10
Bus usb@38200000: 3 USB Device(s) found
       scanning usb for storage devices... 1 Storage Device(s) found

u-boot=> usb info
1: Hub,  USB Revision 3.0
...
3: Mass Storage,  USB Revision 2.0
 - SanDisk Cruzer Edge
...

u-boot=> usb tree
USB device tree:
  1  Hub (5 Gb/s, 0mA)
  |  U-Boot XHCI Host Controller
  |
  +-2  Hub (480 Mb/s, 2mA)
    |
    +-3  Mass Storage (480 Mb/s, 200mA)
         SanDisk Cruzer Edge
```

Access to block devices enumerated on the USB host port is available
using U-Boot generic filesystem interface commands:

```
u-boot=> ls usb 0:1
            ./
            ../
            lost+found/

0 file(s), 3 dir(s)
```

Linux on this system provides access to USB host and peripheral ports
via standard Linux kernel USB stack.

Devices attached to the USB host ports can be conveniently listed using
`usbutils` tool `lsusb`. In case `usbutils` are not part of the system
image, the information can be extracted by traversing sysfs directory
structure in `/sys/bus/usb/devices/` :
```
root@dh-imx8mp-dhcom-pdk2:~# lsusb
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 001 Device 002: ID 0424:2514 Microchip Technology, Inc. (formerly SMSC) USB 2.0 Hub
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
```

### USB Peripheral

To operate the USB OTG port in peripheral mode and set up emulation
of various complex peripherals, it is recommended to use
[libusbgx](https://github.com/linux-usb-gadgets/libusbgx).
It is also possible to emulate simple predefined USB peripherals
by loading a matching kernel module. The `g_zero` USB peripheral
driver which is used for testing purposes can be loaded using the
following command:
```
root@dh-imx8mp-dhcom-pdk2:~# modprobe g_zero
zero gadget.0: Gadget Zero, version: Cinco de Mayo 2008
zero gadget.0: zero ready
dwc2 49000000.usb-otg: bound driver zero
```

Connect USB A-to-miniB cable between the board USB OTG port and host PC.

The newly established USB connection is reported on the board side as follows:
```
dwc2 49000000.usb-otg: new device is high-speed
dwc2 49000000.usb-otg: new device is high-speed
dwc2 49000000.usb-otg: new address 18
```

The newly established USB connection is reported on the host PC side as follows:
```
usb 5-2.2.2.3: new high-speed USB device number 60 using xhci_hcd
usb 5-2.2.2.3: New USB device found, idVendor=0525, idProduct=a4a0, bcdDevice= 6.12
usb 5-2.2.2.3: New USB device strings: Mfr=1, Product=2, SerialNumber=3
usb 5-2.2.2.3: Product: Gadget Zero
usb 5-2.2.2.3: Manufacturer: Linux 6.12.56-stable-standard-00009-ge89a32fe7226 with dwc3-gadget
usb 5-2.2.2.3: SerialNumber: 0123456789.0123456789.0123456789
usbtest 5-2.2.2.3:3.0: Linux gadget zero
usbtest 5-2.2.2.3:3.0: high-speed {control in/out bulk-in bulk-out} tests (+alt)
```
