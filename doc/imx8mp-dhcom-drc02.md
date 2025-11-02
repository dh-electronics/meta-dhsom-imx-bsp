i.MX8M Plus DHCOM SoM on DH DRC02 carrier board
===============================================

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

Connect up to two ethernet cables to ethernet jacks `X9` and `X22`.
The ethernet jack closer to device corner is connected to native
SoC DWMAC `ethsom0`, the ethernet jack closer to device center is
connected to native SoC FEC MAC `ethsom1`.

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
boot_targets=mmc0 mmc1 usb0 pxe
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

The operating system image can be installed onto either microSD card or
into eMMC USER hardware partition.

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
host$ zstd -d dh-image-demo-dh-imx8mp-dhcom-drc02.rootfs.wic.zst
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
    dh-image-demo-dh-imx8mp-dhcom-drc02.rootfs.wic.bmap \
    dh-image-demo-dh-imx8mp-dhcom-drc02.rootfs.wic.zst \
    /dev/sdx
bmaptool: info: block map format version 2.0
bmaptool: info: 400474 blocks of size 4096 (1.5 GiB), mapped 246005 blocks (961.0 MiB or 61.4%)
bmaptool: info: copying image 'dh-image-demo-dh-imx8mp-dhcom-drc02.rootfs.wic' to block device '/dev/sdx' using bmap file 'dh-image-demo-dh-imx8mp-dhcom-drc02.rootfs.wic.bmap'
bmaptool: info: 100% copied
bmaptool: info: synchronizing '/dev/sdx'
bmaptool: info: copying time: 13.2s, copying speed 72.5 MiB/sec
```

It is equally possible to use plain `dd` to write the decompressed
system image into the block device as follows:
```
host$ dd if=dh-image-demo-dh-imx8mp-dhcom-drc02.rootfs.wic \
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
host$ zstd -d dh-image-demo-dh-imx8mp-dhcom-drc02.rootfs.wic.zst
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
    dh-image-demo-dh-imx8mp-dhcom-drc02.rootfs.wic.bmap \
    dh-image-demo-dh-imx8mp-dhcom-drc02.rootfs.wic.zst \
    /dev/mmcblk2
bmaptool: info: block map format version 2.0
bmaptool: info: 400474 blocks of size 4096 (1.5 GiB), mapped 246005 blocks (961.0 MiB or 61.4%)
bmaptool: info: copying image 'dh-image-demo-dh-imx8mp-dhcom-drc02.rootfs.wic' to block device '/dev/mmcblk2' using bmap file 'dh-image-demo-dh-imx8mp-dhcom-drc02.rootfs.wic.bmap'
bmaptool: info: 100% copied
bmaptool: info: synchronizing '/dev/mmcblk2'
bmaptool: info: copying time: 13.2s, copying speed 72.5 MiB/sec
```

It is equally possible to use plain `dd` to write the decompressed
system image into the block device as follows:
```
host$ dd if=dh-image-demo-dh-imx8mp-dhcom-drc02.rootfs.wic \
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
root@dh-imx8mp-dhcom-drc02:~# udevadm info /dev/mtdblock0
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
root@dh-imx8mp-dhcom-drc02:~# dd if=flash-fcfb.bin of=/dev/mtdblock0
3840+0 records in
3840+0 records out
1966080 bytes (2.0 MB, 1.9 MiB) copied, 17.7132 s, 111 kB/s
```

Once the installation completed, reset the board. To perform reset from
Linux kernel, use the following command:

```
root@dh-imx8mp-dhcom-drc02:~# reboot
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
connector `X2`, this is `serial@30860000`. Other serial ports can be
made available by modifying U-Boot control Device Tree.

Linux on this system provides serial console access via `RS232` 5-pin
connector `X2`, this is `30860000.serial`. Linux also provides one
additional serial port accessible via pin header `X23` `30a60000.serial`
and one RS485 ports accessible via connector `X3`, `30880000.serial`.

These ports are accessible via `/dev/ttymxc*` device nodes. To discern
the ports apart, use `udevadm info /dev/ttymxc*` command, which prints
the full hardware path to the selected port:
```
root@dh-imx8mp-dhcom-drc02:~# udevadm info /dev/ttymxc*
P: /devices/platform/soc@0/30800000.bus/30800000.spba-bus/30860000.serial/30860000.serial:0/30860000.serial:0.0/tty/ttymxc0
                                                          ^^^^^^^^^^^^^^^
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
GPIO1_4: output: 1 [x] pmic@25.sd-vsel-gpios
GPIO1_13: output: 0 [x] rs485-rx-en.gpio-hog

Bank GPIO2_:
GPIO2_12: input: 1 [x] mmc@30b50000.cd-gpios

Bank GPIO4_:
GPIO4_2: output: 1 [x] ethernet-phy@2.reset-gpios

Bank GPIO5_:
GPIO5_18: output: 0 [x] i2c@30a40000.scl-gpios
GPIO5_19: output: 0 [x] i2c@30a40000.sda-gpios

Bank gpio@74_:
gpio@74_2: output: 0 [x] regulator-eth-vio.gpio
gpio@74_4: output: 1 [x] ethernet-phy@1.reset-gpios
```

To set a GPIO as Output-High, use `gpio set <pin>` command:
```
u-boot=> gpio set GPIO1_13
gpio: pin GPIO1_13 (gpio 13) value is 1
```

To set a GPIO as Output-Low, use `gpio clear <pin>` command:
```
u-boot=> gpio clear GPIO1_13
gpio: pin GPIO1_13 (gpio 13) value is 0
```

To toggle a GPIO, use `gpio toggle <pin>` command:
```
u-boot=> gpio toggle GPIO1_13
gpio: pin GPIO1_13 (gpio 13) value is 1
u-boot=> gpio toggle GPIO1_13
gpio: pin GPIO1_13 (gpio 13) value is 0
```

Linux on this system provides access to multiple GPIO pins. Access to
GPIOs is provided using GPIO chardev interface and libgpiod. Subset of
GPIO lines is named, which makes them easier to discern in libgpiod
tools output.

To list available GPIOs, use the `gpioinfo` command:
```
root@dh-imx8mp-dhcom-picoitx:~# gpioinfo
gpiochip0 - 32 lines:
gpiochip0 - 32 lines:
        line   0:       "DRC02-In1"             input
        line   1:       unnamed                 input
        line   2:       unnamed                 input
        line   3:       unnamed                 input
        line   4:       unnamed                 output
        line   5:       "DHCOM-I"               output consumer="rts"
        line   6:       "DRC02-HW2"             input
        line   7:       "DRC02-HW0"             input
        line   8:       "DHCOM-B"               input
        line   9:       "DHCOM-A"               input
        line  10:       unnamed                 input
...
```

To get current state of a GPIO, use the `gpioget` command:
```
root@dh-imx8mp-dhcom-picoitx:~# gpioget -c /dev/gpiochip0 9
"9"=inactive
...
```

To set a GPIO as Output-High, use `gpioset ... <line>=1` command:
```
root@dh-imx8mp-dhcom-picoitx:~# gpioset -c /dev/gpiochip0 9=1
```

To set a GPIO as Output-Low, use `gpioset ... <line>=0` command:
```
root@dh-imx8mp-dhcom-picoitx:~# gpioset -c /dev/gpiochip0 9=0
```

It is possible to refer to GPIOs using symbolic names:
```
# Numerical reference to GPIO on gpiochip0 line 9:
root@dh-imx8mp-dhcom-picoitx:~# gpioget -c /dev/gpiochip0 9
"9"=inactive

# Symbolic name reference to GPIO on gpiochip0 line 9:
root@dh-imx8mp-dhcom-picoitx:~# gpioget DHCOM-A
"DHCOM-A"=inactive
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
root@dh-imx8mp-dhcom-drc02:~# cat /sys/devices/platform/soc\@0/30800000.bus/30b50000.mmc/mmc_host/mmc*/mmc*/block/mmcblk*/dev
179:96
^^^ ^^

root@dh-imx8mp-dhcom-drc02:~# ls -la /dev/mmcblk*
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
root@dh-imx8mp-dhcom-drc02:~# cat /sys/devices/platform/soc\@0/30800000.bus/30b60000.mmc/mmc_host/mmc*/mmc*/block/mmcblk*/dev
179:0
^^^ ^

root@dh-imx8mp-dhcom-drc02:~# ls -la /dev/mmcblk*
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
root@dh-imx8mp-dhcom-drc02:~# ip addr show
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
root@dh-imx8mp-dhcom-drc02:~# udevadm info /sys/class/net/ethsom0
P: /devices/platform/soc@0/30800000.bus/30bf0000.ethernet/net/ethsom0
M: ethsom0
...

root@dh-imx8mp-dhcom-drc02:~# udevadm info /sys/class/net/ethsom1
P: /devices/platform/soc@0/30800000.bus/30be0000.ethernet/net/ethsom1
M: ethsom1
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
  +-2  Hub (480 Mb/s, 174mA)
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
root@dh-imx8mp-dhcom-drc02:~# lsusb
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 001 Device 002: ID 04b4:6560 Cypress Semiconductor Corp. CY7C65640 USB-2.0 "TetraHub"
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
```
