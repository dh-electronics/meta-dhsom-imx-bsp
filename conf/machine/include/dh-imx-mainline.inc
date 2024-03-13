# Mainline BSP overrides

MACHINE_FEATURES += " mainline"

# Mesa
PREFERRED_PROVIDER_virtual/egl ?= "mesa-mainline"
PREFERRED_PROVIDER_virtual/libgl ?= "mesa-mainline"
PREFERRED_PROVIDER_virtual/libgles1 ?= "mesa-mainline"
PREFERRED_PROVIDER_virtual/libgles2 ?= "mesa-mainline"
PREFERRED_PROVIDER_virtual/libgles3 ?= "mesa-mainline"
PREFERRED_PROVIDER_virtual/mesa ?= "mesa-mainline"
# Mesa 22.0.y compatibility with dunfell release
PREFERRED_PROVIDER_drm ?= "libdrm-mainline"
PREFERRED_PROVIDER_libdrm ?= "libdrm-mainline"
PREFERRED_PROVIDER_nativesdk-libdrm ?= "nativesdk-libdrm-mainline"
PREFERRED_PROVIDER_wayland-protocols ?= "wayland-protocols-mainline"
PREFERRED_PROVIDER_nativesdk-wayland-protocols ?= "nativesdk-wayland-protocols-mainline"

KERNEL_MODULES_AUTOLOAD += " etnaviv "

PREFERRED_PROVIDER_virtual/kernel ?= "linux-stable"

MACHINE_ESSENTIAL_EXTRA_RDEPENDS += " \
	imx-firmware-sdma-imx7d \
	"
