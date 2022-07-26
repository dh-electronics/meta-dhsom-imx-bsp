# Mainline BSP overrides

# Mesa
PREFERRED_PROVIDER_virtual/egl ?= "mesa-mainline"
PREFERRED_PROVIDER_virtual/libgl ?= "mesa-mainline"
PREFERRED_PROVIDER_virtual/libgl-native ?= "mesa-mainline-native"
PREFERRED_PROVIDER_virtual/nativesdk-libgl ?= "nativesdk-mesa-mainline"
PREFERRED_PROVIDER_virtual/libgles1 ?= "mesa-mainline"
PREFERRED_PROVIDER_virtual/libgles2 ?= "mesa-mainline"
PREFERRED_PROVIDER_virtual/mesa ?= "mesa-mainline"
PREFERRED_PROVIDER_nativesdk-mesa ?= "nativesdk-mesa-mainline"
# Mesa 22.0.y compatibility with dunfell release
PREFERRED_PROVIDER_drm ??= "${@'libdrm-mainline' if (d.getVar('LAYERSERIES_CORENAMES') in ["dunfell"]) else 'libdrm'}"
PREFERRED_PROVIDER_libdrm ??= "${@'libdrm-mainline' if (d.getVar('LAYERSERIES_CORENAMES') in ["dunfell"]) else 'libdrm'}"
PREFERRED_PROVIDER_wayland-protocols ??= "${@'wayland-protocols-mainline' if (d.getVar('LAYERSERIES_CORENAMES') in ["dunfell"]) else 'wayland-protocols'}"

KERNEL_MODULES_AUTOLOAD += " etnaviv "

PREFERRED_PROVIDER_virtual/kernel ?= "linux-stable"

MACHINE_ESSENTIAL_EXTRA_RDEPENDS += " \
	imx-firmware-sdma-imx7d \
	"
