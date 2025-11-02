i.MX6S/D/DL/Q DHCOM SoM on DH DRC02 carrier board
=================================================

# Initial board setup

This section explains how to perform initial hardware setup, how to
assemble the hardware, which cables to connect to which ports, how to
power the hardware on, and finally how to obtain serial console access.

## Insert SoM

Insert SoM provided with the carrier board into slot `U1`.
It is likely the SoM is already populated.

## Connect serial console cable

Connect serial console RS232 cable into `RS232` 5-pin connector `X2`.
This is RS232 up to 12V voltage level connection.

## Connect ethernet cables (optional)

Connect up to two ethernet cables to ethernet jacks `X9`. The ethernet
jack closer to device corner is connected to native SoC FEC MAC `ethsom0`,
the ethernet jack closer to device center is not connected.

## Connect power supply

Connect provided 24V/1A power supply into 3-pin connector `X1`.

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

To boot only from microSD card on DRC02 underside, override `boot_targets`
variable as follows:
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

The operating system image can be installed onto either microSD card on SoM,
microSD card on DRC02 underside, or into eMMC USER hardware partition.

The operating system image installation into either media can be performed
from within U-Boot itself using USB OTG UMS upload, or using microSD or SD
card reader on a host PC, or from running Linux userspace.

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
host$ zstd -d dh-image-demo-dh-imx6-dhcom-drc02.rootfs.wic.zst
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
    dh-image-demo-dh-imx6-dhcom-drc02.rootfs.wic.bmap \
    dh-image-demo-dh-imx6-dhcom-drc02.rootfs.wic.zst \
    /dev/sdx
bmaptool: info: block map format version 2.0
bmaptool: info: 400474 blocks of size 4096 (1.5 GiB), mapped 246005 blocks (961.0 MiB or 61.4%)
bmaptool: info: copying image 'dh-image-demo-dh-imx6-dhcom-drc02.rootfs.wic' to block device '/dev/sdx' using bmap file 'dh-image-demo-dh-imx6-dhcom-drc02.rootfs.wic.bmap'
bmaptool: info: 100% copied
bmaptool: info: synchronizing '/dev/sdx'
bmaptool: info: copying time: 13.2s, copying speed 72.5 MiB/sec
```

It is equally possible to use plain `dd` to write the decompressed
system image into the block device as follows:
```
host$ dd if=dh-image-demo-dh-imx6-dhcom-drc02.rootfs.wic \
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
host$ zstd -d dh-image-demo-dh-imx6-dhcom-drc02.rootfs.wic.zst
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
    dh-image-demo-dh-imx6-dhcom-drc02.rootfs.wic.bmap \
    dh-image-demo-dh-imx6-dhcom-drc02.rootfs.wic.zst \
    /dev/mmcblk2
bmaptool: info: block map format version 2.0
bmaptool: info: 400474 blocks of size 4096 (1.5 GiB), mapped 246005 blocks (961.0 MiB or 61.4%)
bmaptool: info: copying image 'dh-image-demo-dh-imx6-dhcom-drc02.rootfs.wic' to block device '/dev/mmcblk2' using bmap file 'dh-image-demo-dh-imx6-dhcom-drc02.rootfs.wic.bmap'
bmaptool: info: 100% copied
bmaptool: info: synchronizing '/dev/mmcblk2'
bmaptool: info: copying time: 13.2s, copying speed 72.5 MiB/sec
```

It is equally possible to use plain `dd` to write the decompressed
system image into the block device as follows:
```
host$ dd if=dh-image-demo-dh-imx6-dhcom-drc02.rootfs.wic \
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
root@dh-imx6-dhcom-drc02:~# udevadm info /dev/mtdblock0
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
root@dh-imx6-dhcom-drc02:~# dd if=flash.bin of=/dev/mtdblock0
3840+0 records in
3840+0 records out
1966080 bytes (2.0 MB, 1.9 MiB) copied, 17.7132 s, 111 kB/s
```

Once the installation completed, reset the board. To perform reset from
Linux kernel, use the following command:

```
root@dh-imx6-dhcom-drc02:~# reboot
```

### U-Boot bootloader recovery (using USB SDPS upload)

While it may be possible to perform USB SDP based bootloader recovery on
this board directly, the procedure is highly non-trivial. It is recommended
to remove the SoM and insert it into another board, for example the PDK2 or
PDK3, and perform bootloader recovery there. Please contact the vendor.

# IO access

This section describe access to various IO of this system.

## Serial ports and UARTs

U-Boot on this system provides serial console access via `RS232` 5-pin
connector `X2`, this is `serial@2020000`. Other serial ports can be
made available by modifying U-Boot control Device Tree.

Linux on this system provides serial console access via `RS232` 5-pin
connector `X2`, this is `2020000.serial`. Linux also provides one
additional serial port accessible via pin header `X23` `21f0000.serial`
and one RS485 ports accessible via connector `X3`, `21f4000.serial`.

These ports are accessible via `/dev/ttymxc*` device nodes. To discern
the ports apart, use `udevadm info /dev/ttymxc*` command, which prints
the full hardware path to the selected port:
```
root@dh-imx6-dhcom-drc02:~# udevadm info /dev/ttymxc*
P: /devices/platform/soc/2000000.bus/2000000.spba-bus/2020000.serial/2020000.serial:0/2020000.serial:0.0/tty/ttymxc0
                                                      ^^^^^^^^^^^^^^
M: ttymxc0
   ^^^^^^^
```

To access either serial port, use suitable terminate emulator,
for example `minicom`, `picocom`, `screen`, and many others.

## IO

### GPIOs

U-Boot on this system provides access to multiple GPIO pins.

To list GPIOs and their current state, use the `gpio status` command:
```
u-boot=> gpio status
Bank GPIO1_:
GPIO1_7: output: 0 [x] regulator-eth-vio.gpio
GPIO1_18: output: 0 [x] rs485-rx-en.gpio-hog

Bank GPIO2_:
GPIO2_16: input: 0 [x] HW-code-bit-2
GPIO2_19: input: 0 [x] HW-code-bit-0
GPIO2_30: output: 1 [x] spi@2008000.cs-gpios0

Bank GPIO3_:
GPIO3_22: output: 0 [x] regulator-latch-oe-on.gpio

Bank GPIO4_:
GPIO4_11: output: 1 [x] spi@2008000.cs-gpios1

Bank GPIO5_:
GPIO5_0: output: 1 [x] ethernet@2188000.phy-reset-gpios

Bank GPIO6_:
GPIO6_6: input: 1 [x] HW-code-bit-1
GPIO6_16: input: 1 [x] mmc@2194000.cd-gpios
```

To set a GPIO as Output-High, use `gpio set <pin>` command:
```
u-boot=> gpio set GPIO1_18
gpio: pin GPIO1_18 (gpio 18) value is 1
```

To set a GPIO as Output-Low, use `gpio clear <pin>` command:
```
u-boot=> gpio clear GPIO1_18
gpio: pin GPIO1_18 (gpio 18) value is 0
```

To toggle a GPIO, use `gpio toggle <pin>` command:
```
u-boot=> gpio toggle GPIO1_18
gpio: pin GPIO1_18 (gpio 18) value is 1
u-boot=> gpio toggle GPIO1_18
gpio: pin GPIO1_18 (gpio 18) value is 0
```

Linux on this system provides access to multiple GPIO pins. Access to
GPIOs is provided using GPIO chardev interface and libgpiod. Subset of
GPIO lines is named, which makes them easier to discern in libgpiod
tools output.

To list available GPIOs, use the `gpioinfo` command:
```
root@dh-imx6-dhcom-drc02:~# gpioinfo
gpiochip0 - 32 lines:
        line   0:       unnamed                 input
        line   1:       unnamed                 input
        line   2:       "DHCOM-A"               input
        line   3:       unnamed                 output drive=open-drain consumer=scl
        line   4:       "DHCOM-B"               input
        line   5:       "DHCOM-C"               input
        line   6:       unnamed                 input drive=open-drain consumer=sda
        line   7:       unnamed                 output active-low consumer=regulator-eth-vio
..
```

To get current state of a GPIO, use the `gpioget` command:
```
root@dh-imx6-dhcom-drc02:~# gpioget -c /dev/gpiochip0 2
"2"=inactive
...
```

To set a GPIO as Output-High, use `gpioset ... <line>=1` command:
```
root@dh-imx6-dhcom-drc02:~# gpioset -c /dev/gpiochip0 2=1
```

To set a GPIO as Output-Low, use `gpioset ... <line>=0` command:
```
root@dh-imx6-dhcom-drc02:~# gpioset -c /dev/gpiochip0 2=0
```

It is possible to refer to GPIOs using symbolic names:
```
# Numerical reference to GPIO on gpiochip0 line 2:
root@dh-imx6-dhcom-drc02:~# gpioget -c /dev/gpiochip0 2
"2"=inactive

# Symbolic name reference to GPIO on gpiochip0 line 2:
root@dh-imx6-dhcom-drc02:~# gpioget DHCOM-A
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
root@dh-imx6-dhcom-drc02:~# cat /sys/devices/platform/soc/2100000.bus/2198000.mmc/mmc_host/mmc*/mmc*/block/mmcblk*/dev
179:0
^^^ ^

root@dh-imx6-dhcom-drc02:~# ls -la /dev/mmcblk*
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
root@dh-imx6-dhcom-drc02:~# cat /sys/devices/platform/soc/2100000.bus/219c000.mmc/mmc_host/mmc*/mmc*/block/mmcblk*/dev
179:8
^^^ ^

root@dh-imx6-dhcom-drc02:~# ls -la /dev/mmcblk*
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
root@dh-imx6-dhcom-drc02:~# ip addr show
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
on the carrier board. Access to the USB hub ports is possible via either
USB-A connector `X11` (vertical) or `X24` (90 degrees).

U-Boot on this system provides access to USB host and peripheral ports via
standard U-Boot USB stack. To enumerate USB devices attached to the host
port, use `usb` command:

```
u-boot=> usb reset
resetting USB...
USB EHCI 1.00
Bus usb@2184000: 1 USB Device(s) found
Bus usb@2184200: 4 USB Device(s) found
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
  +-2  Hub (480 Mb/s, 174mA)
    |
    +-3  Mass Storage (480 Mb/s, 200mA)
    |    SanDisk Cruzer Edge
    |
    +-4  See Interface (480 Mb/s, 180mA)
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
root@dh-imx6-dhcom-drc02:~# lsusb
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 001 Device 002: ID 04b4:6560 Cypress Semiconductor Corp. CY7C65640 USB-2.0 "TetraHub"
Bus 001 Device 003: ID 0781:556b SanDisk Corp. Cruzer Edge
Bus 001 Device 004: ID 0a46:9621 Davicom Semiconductor, Inc.
```

### USB LTE modem

This system can be augmented with 596-200 LTE modem expansion board.

The modem must be powered on by first setting `RESET_N` line (`CSI0_VSYNC`)
low, and then by toggling `PWRKEY` line (`SD3_DAT4`) high and low. The
following commands start the modem:

```
root@dh-imx6-dhcom-drc02:~# gpioset -z -c /dev/gpiochip4 21=0
root@dh-imx6-dhcom-drc02:~# gpioset -t 1s,0 -c /dev/gpiochip6 0=1
```

The modem does take a few seconds to boot, after which it enumerates
on USB. The result is visible in `lsusb` output as follows:

```
root@dh-imx6-dhcom-drc02:~# lsusb
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 001 Device 002: ID 04b4:6560 Cypress Semiconductor Corp. CY7C65640 USB-2.0 "TetraHub"
Bus 001 Device 003: ID 0781:556b SanDisk Corp. Cruzer Edge
Bus 001 Device 004: ID 0a46:9621 Davicom Semiconductor, Inc.
Bus 001 Device 005: ID 2c7c:0195 Quectel Wireless Solutions Co., Ltd. EG95 LTE modem
```
