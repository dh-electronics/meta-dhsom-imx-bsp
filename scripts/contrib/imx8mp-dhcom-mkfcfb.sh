#!/bin/sh

#
# SPDX-License-Identifier: GPL-2.0+
#
# Augment i.MX8MP flash.bin with QSPI NOR FCFB header
#

# FCFB header in FlexSPI NOR at 0x400:
# 0x400: 46 43 46 42 | 00 00 01 56 |             | 00 03 03 00
# 0x440:             | 01 01 02 00 |             |
# 0x450: 00 00 00 10 |             |             |
# 0x480: 0b 04 18 08 | 08 30 04 24 |             |
# 0x5c0: 00 01 00 00 | 00 00 01 00 |             |

if [ "$#" -ne 2 ] ; then
	echo "Usage: ${0} <input flash.bin> <output flash-with-fcfb-header.bin>"
	exit 1
fi

if ! [ -e "${1}" ] ; then
	echo "File \"${1}\" not found"
	exit 2
fi

temp=$(mktemp)
dd if=/dev/zero of="${temp}" status=none bs=4096 count=1

echo '0x46 0x43 0x46 0x42' | xxd -r -p | dd of="${temp}" conv=notrunc status=none bs=1 seek=1024
echo '0x00 0x00 0x01 0x56' | xxd -r -p | dd of="${temp}" conv=notrunc status=none bs=1 seek=1028
echo '0x00 0x03 0x03 0x00' | xxd -r -p | dd of="${temp}" conv=notrunc status=none bs=1 seek=1036

echo '0x01 0x01 0x02 0x00' | xxd -r -p | dd of="${temp}" conv=notrunc status=none bs=1 seek=1092
echo '0x00 0x00 0x00 0x10' | xxd -r -p | dd of="${temp}" conv=notrunc status=none bs=1 seek=1104

echo '0x0b 0x04 0x18 0x08' | xxd -r -p | dd of="${temp}" conv=notrunc status=none bs=1 seek=1152
echo '0x08 0x30 0x04 0x24' | xxd -r -p | dd of="${temp}" conv=notrunc status=none bs=1 seek=1156

echo '0x00 0x01 0x00 0x00' | xxd -r -p | dd of="${temp}" conv=notrunc status=none bs=1 seek=1472
echo '0x00 0x00 0x01 0x00' | xxd -r -p | dd of="${temp}" conv=notrunc status=none bs=1 seek=1476

cat "${temp}" "${1}" > "${2}"

echo "File \"${1}\" augmented with FCFB header as file \"${2}\", write \"${2}\" to FlexSPI NOR address 0x0"

rm -f "${temp}"

exit 0
