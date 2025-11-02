i.MX6S/D/DL/Q DHCOM SoM on DH PicoITX carrier board
===================================================

# Initial board setup

This section explains how to perform initial hardware setup, how to
assemble the hardware, which cables to connect to which ports, how to
power the hardware on, and finally how to obtain serial console access.

## Insert SoM

Insert SoM provided with the carrier board into socket `X1`.
It is likely the SoM is already populated.

## Connect serial console cable

Connect serial console RS232 cable into 2x5 pin header `X5`.
This is RS232 up to 12V voltage level connection.

## Connect ethernet cables (optional)

Connect ethernet cable to ethernet jack `U11`.

## Connect power supply

Connect provided 24V/1A power supply into barrel jack `X7` or
compatible supply into plug `X6`.

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
u-boot=> env set boot_targets mmc1
u-boot=> boot
```

To boot only from eMMC card, override `boot_targets` variable as follows:
```
u-boot=> env set boot_targets mmc2
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
u-boot=> env set boot_targets mmc1
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

The operating system image can be installed onto either microSD card or into
eMMC USER hardware partition.

The operating system image installation into either media can be performed
using microSD or SD card reader on a host PC, or from running Linux userspace.

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
host$ zstd -d dh-image-demo-dh-imx6-dhcom-picoitx.rootfs.wic.zst
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
    dh-image-demo-dh-imx6-dhcom-picoitx.rootfs.wic.bmap \
    dh-image-demo-dh-imx6-dhcom-picoitx.rootfs.wic.zst \
    /dev/sdx
bmaptool: info: block map format version 2.0
bmaptool: info: 400474 blocks of size 4096 (1.5 GiB), mapped 246005 blocks (961.0 MiB or 61.4%)
bmaptool: info: copying image 'dh-image-demo-dh-imx6-dhcom-picoitx.rootfs.wic' to block device '/dev/sdx' using bmap file 'dh-image-demo-dh-imx6-dhcom-picoitx.rootfs.wic.bmap'
bmaptool: info: 100% copied
bmaptool: info: synchronizing '/dev/sdx'
bmaptool: info: copying time: 13.2s, copying speed 72.5 MiB/sec
```

It is equally possible to use plain `dd` to write the decompressed
system image into the block device as follows:
```
host$ dd if=dh-image-demo-dh-imx6-dhcom-picoitx.rootfs.wic \
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
mandatory that the system is booted from either microSD or SD card and
specifically not booted from eMMC.

To determine which block device is the eMMC, list block devices with
eMMC BOOT hardware partitions as follows:
```
$ ls -1 /dev/mmcblk*boot*
/dev/mmcblk0boot0
/dev/mmcblk0boot1
```
The listing above which implies the eMMC block device is `/dev/mmcblk0`.
This section assumes that the eMMC block device is recognized as a block
device `/dev/mmcblk0`.

Install system image into the block device. It is recommended to use
[bmaptool](https://github.com/yoctoproject/bmaptool) to expedite the
installation by skipping unused blocks. It is recommended to use up
to date bmaptool version at least 3.6.0 which supports decompression
of ZSTD compressed images, otherwise it is necessary to decompress the
ZSTD compressed images first, as follows:
```
host$ zstd -d dh-image-demo-dh-imx6-dhcom-picoitx.rootfs.wic.zst
```

To prevent any MBR or GPT contamination, it is recommended to erase
previous MBR and GPT partition tables:
```
host$ sgdisk -Z /dev/mmcblk0

host$ fdisk /dev/mmcblk0
Command (m for help): x                     # x to enter expert menu
Expert command (m for help): i              # i to change identifier
Enter the new disk identifier: 0x1234abcd   # pick random identifier
Expert command (m for help): r              # r to return to main menu
Command (m for help): w                     # w to write change to MBR
```

Use bmaptool to write system image into block device as follows:
```
host$ bmaptool copy --bmap \
    dh-image-demo-dh-imx6-dhcom-picoitx.rootfs.wic.bmap \
    dh-image-demo-dh-imx6-dhcom-picoitx.rootfs.wic.zst \
    /dev/mmcblk0
bmaptool: info: block map format version 2.0
bmaptool: info: 400474 blocks of size 4096 (1.5 GiB), mapped 246005 blocks (961.0 MiB or 61.4%)
bmaptool: info: copying image 'dh-image-demo-dh-imx6-dhcom-picoitx.rootfs.wic' to block device '/dev/mmcblk0' using bmap file 'dh-image-demo-dh-imx6-dhcom-picoitx.rootfs.wic.bmap'
bmaptool: info: 100% copied
bmaptool: info: synchronizing '/dev/mmcblk0'
bmaptool: info: copying time: 13.2s, copying speed 72.5 MiB/sec
```

It is equally possible to use plain `dd` to write the decompressed
system image into the block device as follows:
```
host$ dd if=dh-image-demo-dh-imx6-dhcom-picoitx.rootfs.wic \
         of=/dev/mmcblk0 bs=4M
```

This system uses GPT GUID Partition Table. It is highly recommended to
randomize GUIDs after writing system image to storage to avoid identical
PARTUUID for multiple partitions on different storage media in the system.
Identical PARTUUID for multiple partitions may lead to system using an
unexpected root device, which accidentally shares the same PARTUUID. To
randomize PARTUUID, use the following command:
```
host$ sgdisk -G /dev/mmcblk0
```

Once the installation completed, reboot the system and attempt to
boot from the eMMC.

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
0x00_0000..0x00_03ff ... UNUSED
0x04_0400..0x0f_ffff ... U-Boot
0x10_0000..0x10_ffff ... U-Boot environment (copy 1)
0x11_0000..0x11_ffff ... U-Boot environment (copy 2)
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
u-boot=> env set dfu_alt_info "sf 0:0=flash-bin raw 0x0 0x200000"
u-boot=> dfu 0 sf
```

The system will now enumerate on the host PC as follows:
```
host$ dmesg -w
usb 5-2.2.2.1: new high-speed USB device number 21 using xhci_hcd
usb 5-2.2.2.1: New USB device found, idVendor=0525, idProduct=a4a5, bcdDevice=7e.a1
usb 5-2.2.2.1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
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

Found DFU: [0525:a4a5] ver=7ea1, devnum=28, cfg=1, intf=0, path="5-2.2.2.4", alt=0, name="flash-bin", serial="UNKNOWN"
```

Install bootloader into SPI NOR using dfu-util as follows. The bootloader
consists of single combined file which contains both U-Boot SPL and U-Boot
uImage, `u-boot-with-spl.imx`. The bootloader image `u-boot-with-spl.imx`
has to be padded to offset 0x400 or 1024 Bytes to be suitable for SPI NOR
boot. The resulting padded file is then sent to the board using `dfu-util`.

Create 1024 Byte long padding:
```
hostpc$ dd if=/dev/zero of=pad.bin bs=1024 count=1
```

Prepend 1024 Byte long padding in front of `u-boot-with-spl.imx`
and generate padded file called `flash.bin`:
```
hostpc$ cat pad.bin u-boot-with-spl.imx > flash.bin
```

Upload padded file to the board:
```
hostpc$ dfu-util -w -a 0 -D flash.bin
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
Setting Alternate Interface #0 ...
Determining device status...
DFU state(2) = dfuIDLE, status(0) = No error condition is present
DFU mode device DFU version 0110
Device returned transfer size 4096
Copying data from PC to DFU device
Download        [=========================] 100%       940872 bytes
Download done.
DFU state(7) = dfuMANIFEST, status(0) = No error condition is present
DFU state(2) = dfuIDLE, status(0) = No error condition is present
Done!
```

Once the installation completed, terminate DFU from U-Boot console
by pressing `Ctrl + C`, then reset the board.

```
u-boot=> dfu 0 sf
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
from bootloader binaries located on either SD, microSD card or eMMC card.

Read bootloader update from PDK2 SD and write to SPI NOR:
```
u-boot=> run update_sf
928080 bytes read in 46 ms (19.2 MiB/s)
SF: Detected s25fl116k with page size 256 Bytes, erase size 4 KiB, total 2 MiB
device 0 offset 0x400, size 0xe2950
919888 bytes written, 8192 bytes skipped in 18.412s, speed 51613 B/s
```

Read bootloader update from eMMC and write to SPI NOR:
```
u-boot=> load mmc 2:1 ${loadaddr} /boot/u-boot-with-spl.imx && sf probe && sf update ${loadaddr} 0x400 ${filesize}
928080 bytes read in 47 ms (18.8 MiB/s)
SF: Detected s25fl116k with page size 256 Bytes, erase size 4 KiB, total 2 MiB
device 0 offset 0x400, size 0xe2950
919888 bytes written, 8192 bytes skipped in 18.412s, speed 51613 B/s
```

Read bootloader update from microSD and write to SPI NOR:
```
u-boot=> load mmc 1:1 ${loadaddr} /boot/u-boot-with-spl.imx && sf probe && sf update ${loadaddr} 0x400 ${filesize}
928080 bytes read in 45 ms (19.7 MiB/s)
SF: Detected s25fl116k with page size 256 Bytes, erase size 4 KiB, total 2 MiB
device 0 offset 0x400, size 0xe2950
919888 bytes written, 8192 bytes skipped in 18.412s, speed 51613 B/s
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
root@dh-imx6-dhcom-picoitx:~# udevadm info /dev/mtdblock0
P: /devices/platform/soc/2000000.bus/2000000.spba-bus/2008000.spi/spi_master/spi0/spi0.0/mtd/mtd0/mtdblock0
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

The bootloader image `u-boot-with-spl.imx` has to be padded to offset
0x400 or 1024 Bytes to be suitable for SPI NOR boot. The resulting padded
file is then written to the SPI NOR.

Create 1024 Byte long padding:
```
hostpc$ dd if=/dev/zero of=pad.bin bs=1024 count=1
```

Prepend 1024 Byte long padding in front of `u-boot-with-spl.imx`
and generate padded file called `flash.bin`:
```
hostpc$ cat pad.bin u-boot-with-spl.imx > flash.bin
```

Use the following command to write U-Boot to SPI NOR:
```
root@dh-imx6-dhcom-picoitx:~# dd if=flash.bin of=/dev/mtdblock0
3840+0 records in
3840+0 records out
1966080 bytes (2.0 MB, 1.9 MiB) copied, 17.7132 s, 111 kB/s
```

Once the installation completed, reset the board. To perform reset from
Linux kernel, use the following command:

```
root@dh-imx6-dhcom-picoitx:~# reboot
```

### U-Boot bootloader recovery (using USB SDP upload)

While it may be possible to perform USB SDP based bootloader recovery on
this board directly, the procedure is highly non-trivial. It is recommended
to remove the SoM and insert it into another board, for example the PDK2,
and perform bootloader recovery there. Please contact the vendor.

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

 - DH 626-100 adapter card with Chefree CH101OLHLWH-002 LVDS display attached to it.
   `imx6qdl-dhcom-picoitx-overlay-626-100-x2-ch101olhlwh.dtbo`

## List available Device Tree Overlays (from U-Boot)

To list Device Tree Overlays supported by the current operating system image,
inspect the Linux kernel fitImage from within U-Boot as follows.

First, load the kernel fitImage from SD or eMMC into memory:
```
u-boot=> load mmc 1:1 ${loadaddr} boot/fitImage
7787180 bytes read in 362 ms (20.5 MiB/s)
```

Second, list the available fitImage configurations, which also
match the available base Device Tree and Device Tree Overlays:
```
u-boot=> iminfo $loadaddr

## Checking Image at 12000000 ...
   FIT image found
   FIT description: Kernel fitImage for DH Linux Distribution/6.12.56+git/dh-imx6-dhcom-picoitx
    Image 0 (kernel-1)
     Description:  Linux kernel
     Type:         Kernel Image
     Compression:  uncompressed
     Data Start:   0x120000fc
     Data Size:    7722696 Bytes = 7.4 MiB
     Architecture: ARM
     OS:           Linux
     Load Address: 0x17800000
     Entry Point:  0x17800000
     Hash algo:    sha256
     Hash value:   943f73114cc7678c0f5023b3c7dee5d5d80a72817f79d9b5df4f27e53505cf38
    Image 1 (fdt-imx6dl-dhcom-picoitx.dtb)
     Description:  Flattened Device Tree blob
     Type:         Flat Device Tree
     Compression:  uncompressed
     Data Start:   0x1275d8dc
     Data Size:    58421 Bytes = 57.1 KiB
     Architecture: ARM
     Load Address: 0x1ff00000
     Hash algo:    sha256
     Hash value:   631dfd78de233369c48b10a3e06624ada82a5ea71c6f4fe3b362b080ccb55026
    Image 2 (fdt-imx6qdl-dhcom-picoitx-overlay-626-100-x2-ch101olhlwh.dtbo)
     Description:  Flattened Device Tree blob
     Type:         Flat Device Tree
     Compression:  uncompressed
     Data Start:   0x1276be28
     Data Size:    3655 Bytes = 3.6 KiB
     Architecture: ARM
     Load Address: 0x1ff80000
     Hash algo:    sha256
     Hash value:   6604f7e3aeb960aba8a16c93ba37c9bd4cc26baf8e5cee22be9e9805194885ad
    Default Configuration: 'conf-imx6dl-dhcom-picoitx.dtb'
    Configuration 0 (conf-imx6dl-dhcom-picoitx.dtb)
     Description:  1 Linux kernel, FDT blob
     Kernel:       kernel-1
     FDT:          fdt-imx6dl-dhcom-picoitx.dtb
     Hash algo:    sha256
     Hash value:   unavailable
    Configuration 1 (conf-imx6qdl-dhcom-picoitx-overlay-626-100-x2-ch101olhlwh.dtbo)
     Description:  0 FDT blob
     Kernel:       unavailable
     FDT:          fdt-imx6qdl-dhcom-picoitx-overlay-626-100-x2-ch101olhlwh.dtbo
     Hash algo:    sha256
     Hash value:   unavailable
## Checking hash(es) for FIT Image at 12000000 ...
   Hash(es) for Image 0 (kernel-1): sha256+
   Hash(es) for Image 1 (fdt-imx6dl-dhcom-picoitx.dtb): sha256+
   Hash(es) for Image 2 (fdt-imx6qdl-dhcom-picoitx-overlay-626-100-x2-ch101olhlwh.dtbo): sha256+
```

The Device Tree and Device Tree Overlays lists below are based on fitImage
configuration listing printed in the example above, with the `conf-` prefix
removed.

The listing contains one base Device Tree:

- `imx6dl-dhcom-picoitx.dtb`

The listing contains the following Device Tree Overlays:

- `imx6qdl-dhcom-picoitx-overlay-626-100-x2-ch101olhlwh.dtbo`

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

To configure the system to use `imx6dl-dhcom-picoitx.dtb` base Device
Tree and apply additional `imx6qdl-dhcom-picoitx-overlay-626-100-x2-ch101olhlwh.dtbo`
Device Tree Overlay, configure the `loaddtos` environment variable as
follows:
```
                     .-----------------------------.----- '#' Separator
                     |                             |
                     v                             v
=> env set loaddtos '#conf-imx6dl-dhcom-picoitx.dtb#conf-imx6qdl-dhcom-picoitx-overlay-626-100-x2-ch101olhlwh.dtbo'
                       ^                             ^
                       |                             |
                       |                             '--- 626-100 display DTO
                       |
                       '--------------------------------- Base Device Tree
```

To make configuration persistent, store U-Boot environment:
```
=> env save
```

To boot the system with additional DTO applied:
```
u-boot=> env set loaddtos '#conf-imx6dl-dhcom-picoitx.dtb#conf-imx6qdl-dhcom-picoitx-overlay-626-100-x2-ch101olhlwh.dtbo'
u-boot=> boot
MMC Device 0 not found
no mmc device at slot 0
switch to partitions #0, OK
mmc1 is current device
Scanning mmc 1:1...
Found U-Boot script /boot/boot.scr
6667 bytes read in 2 ms (3.2 MiB/s)
## Executing script at 14000000
7787180 bytes read in 363 ms (20.5 MiB/s)
Booting the Linux kernel...
## Loading kernel (any) from FIT Image at 12000000 ...
   Using 'conf-imx6dl-dhcom-picoitx.dtb' configuration
   Trying 'kernel-1' kernel subimage
     Description:  Linux kernel
     Type:         Kernel Image
     Compression:  uncompressed
     Data Start:   0x120000fc
     Data Size:    7722696 Bytes = 7.4 MiB
     Architecture: ARM
     OS:           Linux
     Load Address: 0x17800000
     Entry Point:  0x17800000
     Hash algo:    sha256
     Hash value:   943f73114cc7678c0f5023b3c7dee5d5d80a72817f79d9b5df4f27e53505cf38
   Verifying Hash Integrity ... sha256+ OK
## Loading fdt (any) from FIT Image at 12000000 ...
   Using 'conf-imx6dl-dhcom-picoitx.dtb' configuration
   Trying 'fdt-imx6dl-dhcom-picoitx.dtb' fdt subimage
     Description:  Flattened Device Tree blob
     Type:         Flat Device Tree
     Compression:  uncompressed
     Data Start:   0x1275d8dc
     Data Size:    58421 Bytes = 57.1 KiB
     Architecture: ARM
     Load Address: 0x1ff00000
     Hash algo:    sha256
     Hash value:   631dfd78de233369c48b10a3e06624ada82a5ea71c6f4fe3b362b080ccb55026
   Verifying Hash Integrity ... sha256+ OK
   Loading fdt from 0x1275d8dc to 0x1ff00000
   Loading Device Tree to 1ffee000, end 1fffffff ... OK
Working FDT set to 1ffee000
## Loading fdt (any) from FIT Image at 12000000 ...
   Using 'conf-imx6qdl-dhcom-picoitx-overlay-626-100-x2-ch101olhlwh.dtbo' configuration
   Trying 'fdt-imx6qdl-dhcom-picoitx-overlay-626-100-x2-ch101olhlwh.dtbo' fdt subimage
     Description:  Flattened Device Tree blob
     Type:         Flat Device Tree
     Compression:  uncompressed
     Data Start:   0x1276be28
     Data Size:    3655 Bytes = 3.6 KiB
     Architecture: ARM
     Load Address: 0x1ff80000
     Hash algo:    sha256
     Hash value:   6604f7e3aeb960aba8a16c93ba37c9bd4cc26baf8e5cee22be9e9805194885ad
   Verifying Hash Integrity ... sha256+ OK
   Booting using the fdt blob at 0x1ffee000
Working FDT set to 1ffee000
   Loading Kernel Image to 17800000
   Loading Device Tree to 1ffdc000, end 1ffedb58 ... OK
Working FDT set to 1ffdc000

Starting kernel ...
```

# IO access

This section describe access to various IO of this system.

## Serial ports and UARTs

U-Boot on this system provides serial console access via 2x5 pin
header `X5`, this is `serial@2020000`. Other serial ports can be
made available by modifying U-Boot control Device Tree.

Linux on this system provides serial console access via 2x5 pin
header `X5`, this is `2020000.serial`. Linux also provides one
additional serial port accessible via display connector `X2`,
`21f0000.serial` and one RS485 port on external connector `X8`
`21f4000.serial` .

These ports are accessible via `/dev/ttymxc*` device nodes. To
discern the ports apart, use `udevadm info /dev/ttymxc*` command,
which prints the full hardware path to the selected port:
```
root@dh-imx6-dhcom-picoitx:~# udevadm info /dev/ttymxc*
P: /devices/platform/soc/2000000.bus/2000000.spba-bus/2020000.serial/2020000.serial:0/2020000.serial:0.0/tty/ttymxc0
                                                      ^^^^^^^^^^^^^^
M: ttymxc0
   ^^^^^^^
```

To access either serial port, use suitable terminate emulator,
for example `minicom`, `picocom`, `screen`, and many others.

## IO

### LEDs

U-Boot on this system provides access to one LED via `led` command.

To list available LEDs and their current state, use the `led list` command:
```
u-boot=> led list
yellow:indicator      off
```

To enable an LED, use `led <led_label> on` command:
```
u-boot=> led yellow:indicator on
```

To disable an LED, use `led <led_label> off` command:
```
u-boot=> led yellow:indicator off
```

Linux on this system provides access to one LED via sysfs LED API.

To enable an LED, write 1 into matching sysfs LED attribute:
```
root@dh-imx6-dhcom-picoitx:~# echo 1 > /sys/class/leds/yellow\:indicator/brightness
```

To disable an LED, write 0 into matching sysfs LED attribute:
```
root@dh-imx6-dhcom-picoitx:~# echo 0 > /sys/class/leds/yellow\:indicator/brightness
```

### GPIOs

U-Boot on this system provides access to multiple GPIO pins.

To list GPIOs and their current state, use the `gpio status` command:
```
u-boot=> gpio status
Bank GPIO1_:
GPIO1_7: output: 0 [x] regulator-eth-vio.gpio

Bank GPIO2_:
GPIO2_16: input: 0 [x] HW-code-bit-2
GPIO2_19: input: 0 [x] HW-code-bit-0
GPIO2_30: output: 1 [x] spi@2008000.cs-gpios0

Bank GPIO3_:
GPIO3_22: output: 0 [x] regulator-latch-oe-on.gpio

Bank GPIO4_:
GPIO4_8: output: 0 [x] led-0.gpios
GPIO4_11: output: 1 [x] spi@2008000.cs-gpios1

Bank GPIO5_:
GPIO5_0: output: 1 [x] ethernet@2188000.phy-reset-gpios

Bank GPIO6_:
GPIO6_6: input: 1 [x] HW-code-bit-1

Bank GPIO7_:
GPIO7_8: input: 0 [x] mmc@2198000.cd-gpios
```

To set a GPIO as Output-High, use `gpio set <pin>` command:
```
u-boot=> gpio set GPIO4_8
gpio: pin GPIO4_8 (gpio 104) value is 1
```

To set a GPIO as Output-Low, use `gpio clear <pin>` command:
```
u-boot=> gpio clear GPIO4_8
gpio: pin GPIO4_8 (gpio 104) value is 0
```

To toggle a GPIO, use `gpio toggle <pin>` command:
```
u-boot=> gpio toggle GPIO4_8
gpio: pin GPIO4_8 (gpio 104) value is 1
u-boot=> gpio toggle GPIO4_8
gpio: pin GPIO4_8 (gpio 104) value is 0
```

Linux on this system provides access to multiple GPIO pins. Access to
GPIOs is provided using GPIO chardev interface and libgpiod. Subset of
GPIO lines is named, which makes them easier to discern in libgpiod
tools output.

To list available GPIOs, use the `gpioinfo` command:
```
root@dh-imx6-dhcom-picoitx:~# gpioinfo
gpiochip0 - 32 lines:
        line   0:       unnamed                 input
        line   1:       unnamed                 input
        line   2:       "DHCOM-A"               input
        line   3:       unnamed                 output drive=open-drain consumer=scl
        line   4:       "DHCOM-B"               output active-low consumer="reset"
        line   5:       "PicoITX-In2"           input
        line   6:       unnamed                 input drive=open-drain consumer=sda
        line   7:       unnamed                 output active-low consumer=regulator-eth-vio
...
```

To get current state of a GPIO, use the `gpioget` command:
```
root@dh-imx6-dhcom-picoitx:~# gpioget -c /dev/gpiochip0 2
"2"=inactive
...
```

To set a GPIO as Output-High, use `gpioset ... <line>=1` command:
```
root@dh-imx6-dhcom-picoitx:~# gpioset -c /dev/gpiochip0 2=1
```

To set a GPIO as Output-Low, use `gpioset ... <line>=0` command:
```
root@dh-imx6-dhcom-picoitx:~# gpioset -c /dev/gpiochip0 2=0
```

It is possible to refer to GPIOs using symbolic names:
```
# Numerical reference to GPIO on gpiochip0 line 2:
root@dh-imx6-dhcom-picoitx:~# gpioget -c /dev/gpiochip0 2
"2"=inactive

# Symbolic name reference to GPIO on gpiochip0 line 2:
root@dh-imx6-dhcom-picoitx:~# gpioget DHCOM-A
"DHCOM-A"=inactive
```

Note that once the `gpioset` command exits, the line returns to undefined state.

## Storage

### MicroSD

U-Boot on this system provides access to microSD card via standard MMC and
block device interface. To detect and print information about the microSD
card, use `mmc dev` and `mmc info` commands. The microSD card is MMC device
number 1:
```
u-boot=> mmc dev 1
switch to partitions #0, OK
mmc1 is current device

u-boot=> mmc info
Device: FSL_SDHC
Manufacturer ID: 1b
OEM: 534d
Name: 00000
Bus Speed: 49500000
Mode: SD High Speed (50MHz)
Rd Block Len: 512
SD version 3.0
High Capacity: Yes
Capacity: 14.9 GiB
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

u-boot=> ls mmc 1:1
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
/dev/disk/by-path/platform-2198000.mmc
```

In case the deterministic device name symlink is not available, it is possible
to resolve microSD card block device to `/dev/mmcblk*` device node manually by
reading out the character device major and minor numbers from sysfs, and then
by performing look up in the `/dev/` directory, using the following commands.
In the example below, major and minor numbers for microSD card are 179 and 0,
which are represented by device node `/dev/mmcblk1`:
```
root@dh-imx6-dhcom-picoitx:~# cat /sys/devices/platform/soc/2100000.bus/2198000.mmc/mmc_host/mmc*/mmc*/block/mmcblk*/dev
179:0
^^^ ^

root@dh-imx6-dhcom-picoitx:~# ls -la /dev/mmcblk*
...
brw-rw---- 1 root disk 179,  0 Mar 10 03:53 /dev/mmcblk1
                       ^^^   ^              ^^^^^^^^^^^^
...
```

### eMMC

U-Boot on this system provides access to eMMC card via standard MMC and
block device interface. To detect and print information about the eMMC
card, use `mmc dev` and `mmc info` commands. The eMMC card is MMC device
number 2:
```
u-boot=> mmc dev 2
switch to partitions #0, OK
mmc2(part 0) is current device

u-boot=> mmc info
Device: FSL_SDHC
Manufacturer ID: 45
OEM: 0
Name: SEM08G
Bus Speed: 49500000
Mode: MMC High Speed (52MHz)
Rd Block Len: 512
MMC version 4.4.1
High Capacity: Yes
Capacity: 7.3 GiB
Bus Width: 8-bit
Erase Group Size: 512 KiB
HC WP Group Size: 16 MiB
User Capacity: 7.3 GiB WRREL
Boot Capacity: 2 MiB ENH
RPMB Capacity: 2 MiB ENH
Boot area 0 is not write protected
Boot area 1 is not write protected
```

Access to filesystem is available using U-Boot generic filesystem interface commands:
```
u-boot=> mmc part

Partition Map for mmc device 2  --   Partition Type: DOS

Part    Start Sector    Num Sectors     UUID            Type
  1     8192            4514192         076c4a2a-01     83 Boot
...

u-boot=> ls mmc 2:1
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
/dev/disk/by-path/platform-219c000.mmc
```

In case the deterministic device name symlink is not available, it is possible
to resolve eMMC card block device to `/dev/mmcblk*` device node manually by
reading out the character device major and minor numbers from sysfs, and then
by performing look up in the `/dev/` directory, using the following commands.
In the example below, major and minor numbers for eMMC card are 179 and 8,
which are represented by device node `/dev/mmcblk2`:
```
root@dh-imx6-dhcom-picoitx:~# cat /sys/devices/platform/soc/2100000.bus/219c000.mmc/mmc_host/mmc*/mmc*/block/mmcblk*/dev
179:8
^^^ ^

root@dh-imx6-dhcom-picoitx:~# ls -la /dev/mmcblk*
...
brw-rw---- 1 root disk 179,  8 Mar 10 03:53 /dev/mmcblk2
                       ^^^   ^              ^^^^^^^^^^^^
...
```

## Network

### Ethernet

U-Boot on this system provides access to one ethernet interface via U-Boot
networking stack. Use `net list` command to list available ethernet interface:
```
u-boot=> net list
eth0 : ethernet@2188000 00:11:22:33:44:55 active
```

To select active ethernet interface, set U-Boot environment variable `ethact`.

Linux on this system provides access to one ethernet interface via Linux
networking stack. This interface is assigned deterministic interface
names via systemd udevd rules.

```
root@dh-imx6-dhcom-picoitx:~# ip addr show
...
4: ethsom0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 ...
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

This system provides one USB host port accessible via USB-A connector `X10`.

U-Boot on this system provides access to USB host and peripheral ports via
standard U-Boot USB stack. To enumerate USB devices attached to the host
port, use `usb` command:

```
u-boot=> usb reset
resetting USB...
USB EHCI 1.00
USB EHCI 1.00
Bus usb@2184000: 1 USB Device(s) found
Bus usb@2184200: 2 USB Device(s) found
       scanning usb for storage devices... 1 Storage Device(s) found

u-boot=> usb info
1: Hub,  USB Revision 2.0
...
2: Mass Storage,  USB Revision 2.0
 - SanDisk Cruzer Edge
...

u-boot=> usb tree
USB device tree:
  1  Hub (480 Mb/s, 0mA)
     u-boot EHCI Host Controller

  1  Hub (480 Mb/s, 0mA)
  |  u-boot EHCI Host Controller
  |
  +-2  Mass Storage (480 Mb/s, 200mA)
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
root@dh-imx6-dhcom-picoitx:~# lsusb
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 002 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
```
