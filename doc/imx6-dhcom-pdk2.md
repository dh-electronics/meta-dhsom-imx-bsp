i.MX6S/D/DL/Q DHCOM SoM on DH PDK2 carrier board
================================================

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

Connect up to one ethernet cable to single ethernet jack
`GB Ethernet` `X34`.

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

To boot only from full size SD card, override `boot_targets` variable as follows:
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

The operating system image can be installed onto either microSD card, full
size SD card or into eMMC USER hardware partition.

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
# SD on PDK2
u-boot=> ums 0 mmc 0
# microSD on DHCOM
u-boot=> ums 0 mmc 1
# eMMC on DHCOM
u-boot=> ums 0 mmc 2
```

The USB mass storage device will now enumerate on the host PC as follows:
```
host$ dmesg -w
usb 5-2.2.2.1: new high-speed USB device number 106 using xhci_hcd
usb 5-2.2.2.1: New USB device found, idVendor=0483, idProduct=5720, bcdDevice= 2.00
usb 5-2.2.2.1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
usb 5-2.2.2.1: Product: USB download gadget
usb 5-2.2.2.1: Manufacturer: DH electronics
usb-storage 5-2.2.2.1:1.0: USB Mass Storage device detected
usb-storage 5-2.2.2.1:1.0: Quirks match for vid 0525 pid a4a5: 10000
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
host$ zstd -d dh-image-demo-dh-imx6-dhcom-pdk2.rootfs.wic.zst
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
    dh-image-demo-dh-imx6-dhcom-pdk2.rootfs.wic.bmap \
    dh-image-demo-dh-imx6-dhcom-pdk2.rootfs.wic.zst \
    /dev/sdx
bmaptool: info: block map format version 2.0
bmaptool: info: 400474 blocks of size 4096 (1.5 GiB), mapped 246005 blocks (961.0 MiB or 61.4%)
bmaptool: info: copying image 'dh-image-demo-dh-imx6-dhcom-pdk2.rootfs.wic' to block device '/dev/sdx' using bmap file 'dh-image-demo-dh-imx6-dhcom-pdk2.rootfs.wic.bmap'
bmaptool: info: 100% copied
bmaptool: info: synchronizing '/dev/sdx'
bmaptool: info: copying time: 13.2s, copying speed 72.5 MiB/sec
```

It is equally possible to use plain `dd` to write the decompressed
system image into the block device as follows:
```
host$ dd if=dh-image-demo-dh-imx6-dhcom-pdk2.rootfs.wic \
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
host$ zstd -d dh-image-demo-dh-imx6-dhcom-pdk2.rootfs.wic.zst
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
    dh-image-demo-dh-imx6-dhcom-pdk2.rootfs.wic.bmap \
    dh-image-demo-dh-imx6-dhcom-pdk2.rootfs.wic.zst \
    /dev/sdx
bmaptool: info: block map format version 2.0
bmaptool: info: 400474 blocks of size 4096 (1.5 GiB), mapped 246005 blocks (961.0 MiB or 61.4%)
bmaptool: info: copying image 'dh-image-demo-dh-imx6-dhcom-pdk2.rootfs.wic' to block device '/dev/sdx' using bmap file 'dh-image-demo-dh-imx6-dhcom-pdk2.rootfs.wic.bmap'
bmaptool: info: 100% copied
bmaptool: info: synchronizing '/dev/sdx'
bmaptool: info: copying time: 13.2s, copying speed 72.5 MiB/sec
```

It is equally possible to use plain `dd` to write the decompressed
system image into the block device as follows:
```
host$ dd if=dh-image-demo-dh-imx6-dhcom-pdk2.rootfs.wic \
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
host$ zstd -d dh-image-demo-dh-imx6-dhcom-pdk2.rootfs.wic.zst
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
    dh-image-demo-dh-imx6-dhcom-pdk2.rootfs.wic.bmap \
    dh-image-demo-dh-imx6-dhcom-pdk2.rootfs.wic.zst \
    /dev/mmcblk2
bmaptool: info: block map format version 2.0
bmaptool: info: 400474 blocks of size 4096 (1.5 GiB), mapped 246005 blocks (961.0 MiB or 61.4%)
bmaptool: info: copying image 'dh-image-demo-dh-imx6-dhcom-pdk2.rootfs.wic' to block device '/dev/mmcblk2' using bmap file 'dh-image-demo-dh-imx6-dhcom-pdk2.rootfs.wic.bmap'
bmaptool: info: 100% copied
bmaptool: info: synchronizing '/dev/mmcblk2'
bmaptool: info: copying time: 13.2s, copying speed 72.5 MiB/sec
```

It is equally possible to use plain `dd` to write the decompressed
system image into the block device as follows:
```
host$ dd if=dh-image-demo-dh-imx6-dhcom-pdk2.rootfs.wic \
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
root@dh-imx6-dhcom-pdk2:~# udevadm info /dev/mtdblock0
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
root@dh-imx6-dhcom-pdk2:~# dd if=flash.bin of=/dev/mtdblock0
3840+0 records in
3840+0 records out
1966080 bytes (2.0 MB, 1.9 MiB) copied, 17.7132 s, 111 kB/s
```

Once the installation completed, reset the board. To perform reset from
Linux kernel, use the following command:

```
root@dh-imx6-dhcom-pdk2:~# reboot
```

### U-Boot bootloader recovery (using USB SDP upload)

This section depends on [dfu-util](https://dfu-util.sourceforge.net/) and
[imx-usb-loader](https://github.com/boundarydevices/imx_usb_loader.git) tools.
These tools must be installed on the host system.

In case the bootloader is damaged, malfunctioning or missing, it is still
possible to recover the system by starting a replacement bootloader using
USB SDP upload.

Make sure the system is powered off and USB OTG cable is connected to port
`USB OTG` `X14`. Short pins 1 and 2 of the SPI NOR. The SPI NOR is a SOIC8
2x4 pins chip located on the top of the SoM, next to the microSD card slot,
closer to the DRAM memory chips. The pins 1 and 2 are the two pins closest
to the DRAM memory chips. Power on the system, wait about one second, then
release the short.

The system will now enumerate on the host PC as follows:
```
host$ dmesg -w
usb 5-2.2.2.4: new high-speed USB device number 44 using xhci_hcd
usb 5-2.2.2.4: New USB device found, idVendor=15a2, idProduct=0054, bcdDevice= 0.01
usb 5-2.2.2.4: New USB device strings: Mfr=1, Product=2, SerialNumber=0
usb 5-2.2.2.4: Product: SE Blank ARIK
usb 5-2.2.2.4: Manufacturer: Freescale SemiConductor Inc
hid-generic 0003:15A2:0054.001F: hiddev0,hidraw7: USB HID v1.10 Device [Freescale SemiConductor Inc  SE Blank ARIK] on usb-0000:47:00.1-2.2.2.4/input0
```

Release the short.

Use `imx-usb-loader` to send U-Boot SPL binary using SDP via USB OTG to the SoC:
```
host$ imx_usb u-boot-with-spl.imx
config file </path/to/imx_usb_loader/imx_usb.conf>
vid=0x066f pid=0x3780 file_name=mx23_usb_work.conf
vid=0x15a2 pid=0x004f file_name=mx28_usb_work.conf
vid=0x15a2 pid=0x0052 file_name=mx50_usb_work.conf
vid=0x15a2 pid=0x0054 file_name=mx6_usb_work.conf
vid=0x15a2 pid=0x0061 file_name=mx6_usb_work.conf
vid=0x15a2 pid=0x0063 file_name=mx6_usb_work.conf
vid=0x15a2 pid=0x0071 file_name=mx6_usb_work.conf
vid=0x15a2 pid=0x007d file_name=mx6_usb_work.conf
vid=0x15a2 pid=0x0080 file_name=mx6ull_usb_work.conf
vid=0x1fc9 pid=0x0128 file_name=mx6_usb_work.conf
vid=0x15a2 pid=0x0076 file_name=mx7_usb_work.conf
vid=0x1fc9 pid=0x0126 file_name=mx7ulp_usb_work.conf
vid=0x15a2 pid=0x0041 file_name=mx51_usb_work.conf
vid=0x15a2 pid=0x004e file_name=mx53_usb_work.conf
vid=0x15a2 pid=0x006a file_name=vybrid_usb_work.conf
vid=0x066f pid=0x37ff file_name=linux_gadget.conf
vid=0x1b67 pid=0x4fff file_name=mx6_usb_sdp_spl.conf
vid=0x0525 pid=0xb4a4 file_name=mx6_usb_sdp_spl.conf
vid=0x1fc9 pid=0x012b file_name=mx8mq_usb_work.conf
vid=0x1fc9 pid=0x0134 file_name=mx8mm_usb_work.conf
vid=0x1fc9 pid=0x013e file_name=mx8mn_usb_work.conf
vid=0x3016 pid=0x1001 file_name=mx8m_usb_sdp_spl.conf
config file </path/to/mx6_usb_work.conf>
parse /path/to/mx6_usb_work.conf
Trying to open device vid=0x15a2 pid=0x0054
Interface 0 claimed
HAB security state: development mode (0x56787856)
== work item
filename u-boot-with-spl.imx
load_size 0 bytes
load_addr 0x00000000
dcd 1
clear_dcd 0
plug 1
jump_mode 3
jump_addr 0x00000000
== end work item
No DCD table

loading binary file(u-boot-with-spl.imx) to 00907400, skip=0, fsize=ec00 type=aa

<<<60416, 60416 bytes>>>
succeeded (security 0x56787856, status 0x88888888)
jumping to 0x00907400
```

The system will now disconnect from the host PC and re-enumerate on the
host PC as follows:
```
host$ dmesg -w
usb 5-2.2.2.4: USB disconnect, device number 44
usb 5-2.2.2.4: new high-speed USB device number 45 using xhci_hcd
usb 5-2.2.2.4: New USB device found, idVendor=0525, idProduct=b4a4, bcdDevice= 5.00
usb 5-2.2.2.4: New USB device strings: Mfr=1, Product=2, SerialNumber=0
usb 5-2.2.2.4: Product: USB download gadget
usb 5-2.2.2.4: Manufacturer: DH electronics
hid-generic 0003:0525:B4A4.0020: hiddev0,hidraw7: USB HID v1.10 Device [DH electronics USB download gadget] on usb-0000:47:00.1-2.2.2.4/input0
```

Use `dfu-util` to send U-Boot uImage using SDP via USB OTG to the SoC:
```
host$ imx_usb u-boot.img
config file </path/to/imx_usb.conf>
vid=0x066f pid=0x3780 file_name=mx23_usb_work.conf
vid=0x15a2 pid=0x004f file_name=mx28_usb_work.conf
vid=0x15a2 pid=0x0052 file_name=mx50_usb_work.conf
vid=0x15a2 pid=0x0054 file_name=mx6_usb_work.conf
vid=0x15a2 pid=0x0061 file_name=mx6_usb_work.conf
vid=0x15a2 pid=0x0063 file_name=mx6_usb_work.conf
vid=0x15a2 pid=0x0071 file_name=mx6_usb_work.conf
vid=0x15a2 pid=0x007d file_name=mx6_usb_work.conf
vid=0x15a2 pid=0x0080 file_name=mx6ull_usb_work.conf
vid=0x1fc9 pid=0x0128 file_name=mx6_usb_work.conf
vid=0x15a2 pid=0x0076 file_name=mx7_usb_work.conf
vid=0x1fc9 pid=0x0126 file_name=mx7ulp_usb_work.conf
vid=0x15a2 pid=0x0041 file_name=mx51_usb_work.conf
vid=0x15a2 pid=0x004e file_name=mx53_usb_work.conf
vid=0x15a2 pid=0x006a file_name=vybrid_usb_work.conf
vid=0x066f pid=0x37ff file_name=linux_gadget.conf
vid=0x1b67 pid=0x4fff file_name=mx6_usb_sdp_spl.conf
vid=0x0525 pid=0xb4a4 file_name=mx6_usb_sdp_spl.conf
vid=0x1fc9 pid=0x012b file_name=mx8mq_usb_work.conf
vid=0x1fc9 pid=0x0134 file_name=mx8mm_usb_work.conf
vid=0x1fc9 pid=0x013e file_name=mx8mn_usb_work.conf
vid=0x3016 pid=0x1001 file_name=mx8m_usb_sdp_spl.conf
config file </path/to/mx6_usb_sdp_spl.conf>
parse /path/to/mx6_usb_sdp_spl.conf
Trying to open device vid=0x0525 pid=0xb4a4
Interface 0 claimed
HAB security state: development mode (0x56787856)
== work item
filename u-boot.img
load_size 0 bytes
load_addr 0x00000000
dcd 1
clear_dcd 0
plug 1
jump_mode 3
jump_addr 0x00000000
== end work item

loading binary file(u-boot.img) to 177fffc0, skip=0, fsize=d4748 type=aa

<<<870216, 870216 bytes>>>
succeeded (security 0x56787856, status 0x88888888)
jumping to 0x177fffc0
```

The system will now disconnect from the host PC as follows:
```
host$ dmesg -w
usb 5-2.2.2.1: USB disconnect, device number 45
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

- DH 497-200 adapter card with EDT ETM0700G0EDH6 Parallel RGB display attached to it
  - `imx6qdl-dhcom-pdk2-overlay-497-200-x12.dtbo`
- DH 505-200 adapter card with Chefree CH101OLHLWH-002 LVDS display attached to it
  - `imx6qdl-dhcom-pdk2-overlay-505-200-x12-ch101olhlwh.dtbo`
- DH 531-100 SPI/I2C board in header X21
  - `imx6qdl-dhcom-pdk2-overlay-531-100-x21.dtbo`
- DH 531-200 SPI/I2C board in header X22
  - `imx6qdl-dhcom-pdk2-overlay-531-100-x22.dtbo`
- DH 560-200 7" LCD board in header X12
  - `imx6qdl-dhcom-pdk2-overlay-560-200-x12.dtbo`

## List available Device Tree Overlays (from U-Boot)

To list Device Tree Overlays supported by the current operating system image,
inspect the Linux kernel fitImage from within U-Boot as follows.

First, load the kernel fitImage from SD or eMMC into memory:
```
u-boot=> load mmc 2:1 ${loadaddr} boot/fitImage
7991684 bytes read in 212 ms (35.9 MiB/s)
```

Second, list the available fitImage configurations, which also
match the available base Device Tree and Device Tree Overlays:
```
u-boot=> iminfo $loadaddr

## Checking Image at 18000000 ...
   FIT image found
   FIT description: Kernel fitImage for DH Linux Distribution/6.12.53+git/dh-imx6-dhcom-pdk2
    Image 0 (kernel-1)
     Description:  Linux kernel
     Type:         Kernel Image
     Compression:  uncompressed
     Data Start:   0x180000fc
     Data Size:    7912928 Bytes = 7.5 MiB
     Architecture: ARM
     OS:           Linux
     Load Address: 0x17800000
     Entry Point:  0x17800000
     Hash algo:    sha256
     Hash value:   73d1ff2da8fcc528693ebe635498c0bc88fbca214825cf4f1b6cfb30c3925ff6
    Image 1 (fdt-imx6q-dhcom-pdk2.dtb)
     Description:  Flattened Device Tree blob
     Type:         Flat Device Tree
     Compression:  uncompressed
     Data Start:   0x1878bff0
     Data Size:    64413 Bytes = 62.9 KiB
     Architecture: ARM
     Load Address: 0x1ff00000
     Hash algo:    sha256
     Hash value:   b5cb1f28530ba381aacab9072e8d1de5f05b076af34747d54d5618101f4e3f6f
    Image 2 (fdt-imx6qdl-dhcom-pdk2-overlay-497-200-x12.dtbo)
     Description:  Flattened Device Tree blob
     Type:         Flat Device Tree
     Compression:  uncompressed
     Data Start:   0x1879bc94
     Data Size:    2403 Bytes = 2.3 KiB
     Architecture: ARM
     Load Address: 0x1ff80000
     Hash algo:    sha256
     Hash value:   2aa7fa2a8f8173372b0b0d31d7959715c939b4788f56c1cb5d2983f159477490
    Image 3 (fdt-imx6qdl-dhcom-pdk2-overlay-531-100-x21.dtbo)
     Description:  Flattened Device Tree blob
     Type:         Flat Device Tree
     Compression:  uncompressed
     Data Start:   0x1879c6fc
     Data Size:    715 Bytes = 715 Bytes
     Architecture: ARM
     Load Address: 0x1ff80000
     Hash algo:    sha256
     Hash value:   c3e5329c9aed580f9c7234fe5fb257d71d463f07e5e1b5f7f440ed27538cb616
    Image 4 (fdt-imx6qdl-dhcom-pdk2-overlay-531-100-x22.dtbo)
     Description:  Flattened Device Tree blob
     Type:         Flat Device Tree
     Compression:  uncompressed
     Data Start:   0x1879cacc
     Data Size:    715 Bytes = 715 Bytes
     Architecture: ARM
     Load Address: 0x1ff80000
     Hash algo:    sha256
     Hash value:   b411084a339baf18077e38377ab9bd72c91f8d6817ed3cd32e47460ef969abbd
    Image 5 (fdt-imx6qdl-dhcom-pdk2-overlay-505-200-x12-ch101olhlwh.dtbo)
     Description:  Flattened Device Tree blob
     Type:         Flat Device Tree
     Compression:  uncompressed
     Data Start:   0x1879cea8
     Data Size:    3827 Bytes = 3.7 KiB
     Architecture: ARM
     Load Address: 0x1ff80000
     Hash algo:    sha256
     Hash value:   8c431dcf2812700383e99413e95954cda231fa0e61e303143c6356b051a155ea
    Image 6 (fdt-imx6qdl-dhcom-pdk2-overlay-560-200-x12.dtbo)
     Description:  Flattened Device Tree blob
     Type:         Flat Device Tree
     Compression:  uncompressed
     Data Start:   0x1879dea0
     Data Size:    2709 Bytes = 2.6 KiB
     Architecture: ARM
     Load Address: 0x1ff80000
     Hash algo:    sha256
     Hash value:   369145774cb62c722016cfaf0b6648e53ae7f187c6ef124467f4e092b590067f
    Default Configuration: 'conf-imx6q-dhcom-pdk2.dtb'
    Configuration 0 (conf-imx6q-dhcom-pdk2.dtb)
     Description:  1 Linux kernel, FDT blob
     Kernel:       kernel-1
     FDT:          fdt-imx6q-dhcom-pdk2.dtb
     Hash algo:    sha256
     Hash value:   unavailable
    Configuration 1 (conf-imx6qdl-dhcom-pdk2-overlay-497-200-x12.dtbo)
     Description:  0 FDT blob
     Kernel:       unavailable
     FDT:          fdt-imx6qdl-dhcom-pdk2-overlay-497-200-x12.dtbo
     Hash algo:    sha256
     Hash value:   unavailable
    Configuration 2 (conf-imx6qdl-dhcom-pdk2-overlay-531-100-x21.dtbo)
     Description:  0 FDT blob
     Kernel:       unavailable
     FDT:          fdt-imx6qdl-dhcom-pdk2-overlay-531-100-x21.dtbo
     Hash algo:    sha256
     Hash value:   unavailable
    Configuration 3 (conf-imx6qdl-dhcom-pdk2-overlay-531-100-x22.dtbo)
     Description:  0 FDT blob
     Kernel:       unavailable
     FDT:          fdt-imx6qdl-dhcom-pdk2-overlay-531-100-x22.dtbo
     Hash algo:    sha256
     Hash value:   unavailable
    Configuration 4 (conf-imx6qdl-dhcom-pdk2-overlay-505-200-x12-ch101olhlwh.dtbo)
     Description:  0 FDT blob
     Kernel:       unavailable
     FDT:          fdt-imx6qdl-dhcom-pdk2-overlay-505-200-x12-ch101olhlwh.dtbo
     Hash algo:    sha256
     Hash value:   unavailable
    Configuration 5 (conf-imx6qdl-dhcom-pdk2-overlay-560-200-x12.dtbo)
     Description:  0 FDT blob
     Kernel:       unavailable
     FDT:          fdt-imx6qdl-dhcom-pdk2-overlay-560-200-x12.dtbo
     Hash algo:    sha256
     Hash value:   unavailable
## Checking hash(es) for FIT Image at 18000000 ...
   Hash(es) for Image 0 (kernel-1): sha256+
   Hash(es) for Image 1 (fdt-imx6q-dhcom-pdk2.dtb): sha256+
   Hash(es) for Image 2 (fdt-imx6qdl-dhcom-pdk2-overlay-497-200-x12.dtbo): sha256+
   Hash(es) for Image 3 (fdt-imx6qdl-dhcom-pdk2-overlay-531-100-x21.dtbo): sha256+
   Hash(es) for Image 4 (fdt-imx6qdl-dhcom-pdk2-overlay-531-100-x22.dtbo): sha256+
   Hash(es) for Image 5 (fdt-imx6qdl-dhcom-pdk2-overlay-505-200-x12-ch101olhlwh.dtbo): sha256+
   Hash(es) for Image 6 (fdt-imx6qdl-dhcom-pdk2-overlay-560-200-x12.dtbo): sha256+
```

The Device Tree and Device Tree Overlays lists below are based on fitImage
configuration listing printed in the example above, with the `conf-` prefix
removed.

The listing contains one base Device Tree:

- `imx6q-dhcom-pdk2.dtb`

The listing contains the following Device Tree Overlays:

- `imx6qdl-dhcom-pdk2-overlay-497-200-x12.dtbo`
- `imx6qdl-dhcom-pdk2-overlay-531-100-x21.dtbo`
- `imx6qdl-dhcom-pdk2-overlay-531-100-x22.dtbo`
- `imx6qdl-dhcom-pdk2-overlay-505-200-x12-ch101olhlwh.dtbo`
- `imx6qdl-dhcom-pdk2-overlay-560-200-x12.dtbo`

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

To configure the system to use `imx6q-dhcom-pdk2.dtb` base Device
Tree and apply additional `imx6qdl-dhcom-pdk2-overlay-560-200-x12.dtbo`
Device Tree Overlay, configure the `loaddtos` environment variable as
follows:
```
                     .-------------------------.----- '#' Separator
                     |                         |
                     v                         v
=> env set loaddtos '#conf-imx6q-dhcom-pdk2.dtb#conf-imx6qdl-dhcom-pdk2-overlay-560-200-x12.dtbo'
                       ^                         ^
                       |                         |
                       |                         '--- 560-200 display DTO
                       |
                       '----------------------------- Base Device Tree
```

To make configuration persistent, store U-Boot environment:
```
=> env save
```

To boot the system with additional DTO applied:
```
u-boot=> env set loaddtos '#conf-imx6q-dhcom-pdk2.dtb#conf-imx6qdl-dhcom-pdk2-overlay-560-200-x12.dtbo'
u-boot=> boot
switch to partitions #0, OK
mmc2(part 0) is current device
Scanning mmc 2:1...
Found U-Boot script /boot/boot.scr
6667 bytes read in 2 ms (3.2 MiB/s)
## Executing script at 14000000
7991684 bytes read in 212 ms (35.9 MiB/s)
Booting the Linux kernel...
## Loading kernel from FIT Image at 18000000 ...
   Using 'conf-imx6q-dhcom-pdk2.dtb' configuration
   Trying 'kernel-1' kernel subimage
     Description:  Linux kernel
     Type:         Kernel Image
     Compression:  uncompressed
     Data Start:   0x180000fc
     Data Size:    7912928 Bytes = 7.5 MiB
     Architecture: ARM
     OS:           Linux
     Load Address: 0x17800000
     Entry Point:  0x17800000
     Hash algo:    sha256
     Hash value:   73d1ff2da8fcc528693ebe635498c0bc88fbca214825cf4f1b6cfb30c3925ff6
   Verifying Hash Integrity ... sha256+ OK
## Loading fdt from FIT Image at 18000000 ...
   Using 'conf-imx6q-dhcom-pdk2.dtb' configuration
   Trying 'fdt-imx6q-dhcom-pdk2.dtb' fdt subimage
     Description:  Flattened Device Tree blob
     Type:         Flat Device Tree
     Compression:  uncompressed
     Data Start:   0x1878bff0
     Data Size:    64413 Bytes = 62.9 KiB
     Architecture: ARM
     Load Address: 0x1ff00000
     Hash algo:    sha256
     Hash value:   b5cb1f28530ba381aacab9072e8d1de5f05b076af34747d54d5618101f4e3f6f
   Verifying Hash Integrity ... sha256+ OK
   Loading fdt from 0x1878bff0 to 0x1ff00000
## Loading fdt from FIT Image at 18000000 ...
   Using 'conf-imx6qdl-dhcom-pdk2-overlay-560-200-x12.dtbo' configuration
   Trying 'fdt-imx6qdl-dhcom-pdk2-overlay-560-200-x12.dtbo' fdt subimage
     Description:  Flattened Device Tree blob
     Type:         Flat Device Tree
     Compression:  uncompressed
     Data Start:   0x1879dea0
     Data Size:    2709 Bytes = 2.6 KiB
     Architecture: ARM
     Load Address: 0x1ff80000
     Hash algo:    sha256
     Hash value:   369145774cb62c722016cfaf0b6648e53ae7f187c6ef124467f4e092b590067f
   Verifying Hash Integrity ... sha256+ OK
   Booting using the fdt blob at 0x1ff00000
Working FDT set to 1ff00000
   Loading Kernel Image to 17800000
   Loading Device Tree to 1ffed000, end 1ffffc4c ... OK
Working FDT set to 1ffed000

Starting kernel ...
```

# IO access

This section describe access to various IO of this system.

## Serial ports and UARTs

U-Boot on this system provides serial console access via `RS232 UART1`
DB9 plug `X8`, this is `serial@2020000`. Other serial ports can be
made available by modifying U-Boot control Device Tree.

Linux on this system provides serial console access via `RS232 UART1`
DB9 plug `X8`, this is `2020000.serial`. Linux also provides two
additional serial ports accessible via pin header `UART2 TTL` `X6`
`21f4000.serial` and `UART3 TTL` `X7` `21f0000.serial` . These ports
are accessible via `/dev/ttymxc*` device nodes. To discern the ports
apart, use `udevadm info /dev/ttymxc*` command, which prints the full
hardware path to the selected port:
```
root@dh-imx6-dhcom-pdk2:~# udevadm info /dev/ttymxc*
P: /devices/platform/soc/2000000.bus/2000000.spba-bus/2020000.serial/2020000.serial:0/2020000.serial:0.0/tty/ttymxc0
                                                      ^^^^^^^^^^^^^^
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
u-boot=> gpio input GPIO1_2
gpio: pin GPIO1_2 (gpio 2) value is 1
u-boot=> echo $?
1

u-boot=> gpio input GPIO1_2
gpio: pin GPIO1_2 (gpio 2) value is 0
u-boot=> echo $?
0
```

Linux on this system provides access to four buttons via input event
device, using `gpio-keys` driver. To access GPIO keys on this platform,
open the matching `/dev/input/event*` event device.

Example using `evtest` tool:

```
root@dh-imx6-dhcom-pdk2:~# evtest
No device specified, trying to scan all of /dev/input/event*
Available devices:
/dev/input/event0:      gpio-keys
Select the device event number [0-0]: 0
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
Event: time 1762123332.180748, type 1 (EV_KEY), code 30 (KEY_A), value 1
Event: time 1762123332.180748, -------------- SYN_REPORT ------------
Event: time 1762123332.313446, type 1 (EV_KEY), code 30 (KEY_A), value 0
Event: time 1762123332.313446, -------------- SYN_REPORT ------------
Event: time 1762123335.693887, type 1 (EV_KEY), code 48 (KEY_B), value 1
Event: time 1762123335.693887, -------------- SYN_REPORT ------------
Event: time 1762123335.851452, type 1 (EV_KEY), code 48 (KEY_B), value 0
Event: time 1762123335.851452, -------------- SYN_REPORT ------------
Event: time 1762123336.207213, type 1 (EV_KEY), code 46 (KEY_C), value 1
Event: time 1762123336.207213, -------------- SYN_REPORT ------------
Event: time 1762123336.375060, type 1 (EV_KEY), code 46 (KEY_C), value 0
Event: time 1762123336.375060, -------------- SYN_REPORT ------------
Event: time 1762123336.731233, type 1 (EV_KEY), code 32 (KEY_D), value 1
Event: time 1762123336.731233, -------------- SYN_REPORT ------------
Event: time 1762123336.886228, type 1 (EV_KEY), code 32 (KEY_D), value 0
Event: time 1762123336.886228, -------------- SYN_REPORT ------------
```

### LEDs

U-Boot on this system provides access to four LEDs via `led` command.

To list available LEDs and their current state, use the `led list` command:
```
u-boot=> led list
led-5      off
led-6      off
led-7      off
led-8      off
```

To enable an LED, use `led <led_label> on` command:
```
u-boot=> led led-5 on
u-boot=> led led-6 on
u-boot=> led led-7 on
u-boot=> led led-8 on
```

To disable an LED, use `led <led_label> off` command:
```
u-boot=> led led-5 off
u-boot=> led led-6 off
u-boot=> led led-7 off
u-boot=> led led-8 off
```

Linux on this system provides access to three LEDs via sysfs LED API,
LED-5 is DH GPIO-E used as touch controller interrupt, and therefore
unavailable to LED subsystem in Linux.

To enable an LED, write 1 into matching sysfs LED attribute:
```
root@dh-imx6-dhcom-pdk2:~# echo 1 > /sys/class/leds/green\:indicator/brightness
root@dh-imx6-dhcom-pdk2:~# echo 1 > /sys/class/leds/green\:indicator_1/brightness
root@dh-imx6-dhcom-pdk2:~# echo 1 > /sys/class/leds/green\:indicator_2/brightness
```

To disable an LED, write 0 into matching sysfs LED attribute:
```
root@dh-imx6-dhcom-pdk2:~# echo 0 > /sys/class/leds/green\:indicator/brightness
root@dh-imx6-dhcom-pdk2:~# echo 0 > /sys/class/leds/green\:indicator_1/brightness
root@dh-imx6-dhcom-pdk2:~# echo 0 > /sys/class/leds/green\:indicator_2/brightness
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
GPIO3_29: output: 1 [x] ethernet@2188000.phy-reset-gpios

Bank GPIO4_:
GPIO4_5: output: 0 [x] led-5.gpios
GPIO4_7: output: 0 [x] led-7.gpios
GPIO4_8: output: 0 [x] led-8.gpios
GPIO4_11: output: 1 [x] spi@2008000.cs-gpios1
GPIO4_20: output: 0 [x] led-6.gpios

Bank GPIO6_:
GPIO6_6: input: 1 [x] HW-code-bit-1
GPIO6_16: input: 0 [x] mmc@2194000.cd-gpios

Bank GPIO7_:
GPIO7_8: input: 0 [x] mmc@2198000.cd-gpios
```

To set a GPIO as Output-High, use `gpio set <pin>` command:
```
u-boot=> gpio set GPIO4_20
gpio: pin GPIO4_20 (gpio 116) value is 1
```

To set a GPIO as Output-Low, use `gpio clear <pin>` command:
```
u-boot=> gpio clear GPIO4_20
gpio: pin GPIO4_20 (gpio 116) value is 0
```

To toggle a GPIO, use `gpio toggle <pin>` command:
```
u-boot=> gpio toggle GPIO4_20
gpio: pin GPIO4_20 (gpio 116) value is 1
u-boot=> gpio toggle GPIO4_20
gpio: pin GPIO4_20 (gpio 116) value is 0
```

Linux on this system provides access to multiple GPIO pins. Access to
GPIOs is provided using GPIO chardev interface and libgpiod. Subset of
GPIO lines is named, which makes them easier to discern in libgpiod
tools output.

To list available GPIOs, use the `gpioinfo` command:
```
root@dh-imx6-dhcom-pdk2:~# gpioinfo
gpiochip0 - 32 lines:
        line   0:       unnamed                 input
        line   1:       unnamed                 input
        line   2:       "DHCOM-A"               input active-low consumer="TA1-GPIO-A"
...
gpiochip6 - 32 lines:
        line   0:       "DHCOM-M"               input
        line   1:       "DHCOM-N"               input
...
```

To get current state of a GPIO, use the `gpioget` command:
```
root@dh-imx6-dhcom-pdk2:~# gpioget -c /dev/gpiochip6 1
"1"=inactive
...
```

To set a GPIO as Output-High, use `gpioset ... <line>=1` command:
```
root@dh-imx6-dhcom-pdk2:~# gpioset -c /dev/gpiochip6 1=1
```

To set a GPIO as Output-Low, use `gpioset ... <line>=0` command:
```
root@dh-imx6-dhcom-pdk2:~# gpioset -c /dev/gpiochip6 1=0
```

It is possible to refer to GPIOs using symbolic names:
```
# Numerical reference to GPIO on gpiochip6 line 1:
root@dh-imx6-dhcom-pdk2:~# gpioget -c /dev/gpiochip6 1
"1"=inactive

# Symbolic name reference to GPIO on gpiochip6 line 1:
root@dh-imx6-dhcom-pdk2:~# gpioget DHCOM-N
"DHCOM-N"=inactive
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
root@dh-imx6-dhcom-pdk2:~# cat /sys/devices/platform/soc/2100000.bus/2198000.mmc/mmc_host/mmc*/mmc*/block/mmcblk*/dev
179:0
^^^ ^

root@dh-imx6-dhcom-pdk2:~# ls -la /dev/mmcblk*
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
root@dh-imx6-dhcom-pdk2:~# cat /sys/devices/platform/soc/2100000.bus/219c000.mmc/mmc_host/mmc*/mmc*/block/mmcblk*/dev
179:8
^^^ ^

root@dh-imx6-dhcom-pdk2:~# ls -la /dev/mmcblk*
...
brw-rw---- 1 root disk 179,  8 Mar 10 03:53 /dev/mmcblk2
                       ^^^   ^              ^^^^^^^^^^^^
...
```

### Full-size SD

U-Boot on this system provides access to PDK2 SD card via standard MMC and
block device interface. To detect and print information about the PDK2 SD
card, use `mmc dev` and `mmc info` commands. The PDK2 SD card is MMC device
number 1:
```
u-boot=> mmc dev 0
switch to partitions #0, OK
mmc0 is current device

u-boot=> mmc info
Device: FSL_SDHC
Manufacturer ID: 3
OEM: 5344
Name: SP16G
Bus Speed: 49500000
Mode: SD High Speed (50MHz)
Rd Block Len: 512
SD version 3.0
High Capacity: Yes
Capacity: 14.2 GiB
Bus Width: 4-bit
Erase Group Size: 512 Bytes
```

Access to filesystem is available using U-Boot generic filesystem interface commands:
```
u-boot=> mmc part

Partition Map for mmc device 0  --   Partition Type: DOS

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

Linux on this system provides access to PDK2 SD card via standard block device
interface. It is recommended to use deterministic device name symlink generated
by `udev` to access block devices. The PDK2 SD card block device is accessible
via the following deterministic device name symlink:
```
/dev/disk/by-path/platform-2194000.mmc
```

In case the deterministic device name symlink is not available, it is possible
to resolve PDK2 SD card block device to `/dev/mmcblk*` device node manually by
reading out the character device major and minor numbers from sysfs, and then
by performing look up in the `/dev/` directory, using the following commands.
In the example below, major and minor numbers for PDK2 SD card are 179 and 32,
which are represented by device node `/dev/mmcblk0`:
```
root@dh-imx6-dhcom-pdk2:~# cat /sys/devices/platform/soc/2100000.bus/2194000.mmc/mmc_host/mmc*/mmc*/block/mmcblk*/dev
179:32
^^^ ^^

root@dh-imx6-dhcom-pdk2:~# ls -la /dev/mmcblk*
...
brw-rw---- 1 root disk 179, 32 Mar 10 03:53 /dev/mmcblk0
                       ^^^  ^^              ^^^^^^^^^^^^
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
root@dh-imx6-dhcom-pdk2:~# ip addr show
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
Bus usb@2184000: Bus usb@2184200: USB EHCI 1.00
scanning bus usb@2184000 for devices... 1 USB Device(s) found
scanning bus usb@2184200 for devices... 3 USB Device(s) found
       scanning usb for storage devices... 1 Storage Device(s) found

u-boot=> usb info
1: Hub,  USB Revision 2.0
...
3: Mass Storage,  USB Revision 2.0
 - SanDisk Cruzer Edge
...

u-boot=> usb tree
USB device tree:
  1  Hub (480 Mb/s, 0mA)
     u-boot EHCI Host Controller

  1  Hub (480 Mb/s, 0mA)
  |  u-boot EHCI Host Controller
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
root@dh-imx6-dhcom-pdk2:~# lsusb
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 001 Device 002: ID 0424:2514 Microchip Technology, Inc. (formerly SMSC) USB 2.0 Hub
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
root@dh-imx6-dhcom-pdk2:~# modprobe g_zero
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
usb 5-2.2.2.4: new high-speed USB device number 18 using xhci_hcd
usb 5-2.2.2.4: New USB device found, idVendor=1a0a, idProduct=badd, bcdDevice= 6.12
usb 5-2.2.2.4: New USB device strings: Mfr=1, Product=2, SerialNumber=0
usb 5-2.2.2.4: Product: Gadget Zero
usb 5-2.2.2.4: Manufacturer: Linux 6.12.51-stable-standard-00010-g9bb1faec694c with 49000000.usb-otg
usb 5-2.2.2.4: SerialNumber: 0123456789.0123456789.0123456789
```
