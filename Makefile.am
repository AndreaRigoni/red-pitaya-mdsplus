SUBDIRS =
if BUILD_MDSPLUS
SUBDIRS += mdsplus
endif
SUBDIRS += src

ACLOCAL_AMFLAGS = -I m4
include Common.am

setup:
	@ echo "Setup environment"
	. $(srcdir)/settings.sh


# //////////////////////////////////////////////////////////////////////////// #
# ///  MDSPLUS /////////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #

.PHONY: mdsplus
mdsplus:
	@ echo "Building mdsplus submodule"
if BUILD_MDSPLUS
	@ $(MAKE) -C mdsplus all
endif



# //////////////////////////////////////////////////////////////////////////// #
# ///  OLD MAKEFILE FROM REDPITAYA  ////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #


INSTALL_DIR=build
TARGET=target


# directories
FPGA_DIR        = fpga
OS_TOOLS_DIR    = OS/tools
ECOSYSTEM_DIR   = Applications/ecosystem

# targets
FPGA            = $(FPGA_DIR)/out/red_pitaya.bit
FSBL            = $(FPGA_DIR)/sdk/fsbl/executable.elf
DTS             = $(FPGA_DIR)/sdk/dts/system.dts
DEVICETREE      = $(TMP)/devicetree.dtb
UBOOT           = $(TMP)/u-boot.elf
LINUX           = $(TMP)/uImage
BOOT_UBOOT      = $(TMP)/boot.bin


TOOLCHAIN_DIR   = /opt/linaro/gcc-linaro-4.9-2014.11-x86_64_arm-linux-gnueabihf
CROSS_COMPILE   = arm-linux-gnueabihf-

################################################################################
# tarball
################################################################################


define GREET_MSG
##############################################################################
# Red Pitaya GNU/Linux Ecosystem for RFX transient recorder
# Version: $(VER)
# Branch: $(GIT_BRANCH_LOCAL)
# Build: $(BUILD_NUMBER)
# Commit: $(GIT_COMMIT)
##############################################################################
endef
export GREET_MSG


all: setup zip

$(DL):
	mkdir -p $@

$(TMP):
	mkdir -p $@

$(TARGET): $(BOOT_UBOOT) u-boot $(DEVICETREE) $(LINUX) buildroot
	mkdir -p               $(TARGET)
	cp $(BOOT_UBOOT)       $(TARGET)/boot.bin
	cp $(DEVICETREE)       $(TARGET)
	cp $(LINUX)            $(TARGET)
	make -C $(LINUX_DIR) ARCH=arm CFLAGS=$(LINUX_CFLAGS) -j $(MAKE_PROCESS) \
	   PATH="${PATH}:${TOOLCHAIN_DIR}" CROSS_COMPILE=${CROSS_COMPILE} \
	   modules_install INSTALL_MOD_PATH=${TARGET}	
	mkdir -p               $(TARGET)/fpga
	cp $(FPGA)             $(TARGET)/fpga/fpga.bit
	cp -r $(INSTALL_DIR)/* $(TARGET)
	cp -r $(srcdir)/OS/filesystem/*  $(TARGET)
	@echo "$$GREET_MSG" >  $(TARGET)/version.txt
	cp $(srcdir)/OS/debian/overlay/etc/hostapd/hostapd.conf $(TARGET)/hostapd.conf
#	cp /opt/linaro/sysroot-linaro-eglibc-gcc4.9-2014.11-arm-linux-gnueabihf/usr/lib/libstdc++.so.6 $(TARGET)/lib

zip: $(TARGET)
	cd $(TARGET); zip -r ../$(ECOSYSEM_ZIP) *





################################################################################
# FPGA build provides: $(FSBL), $(FPGA), $(DEVICETREE).
################################################################################

.PHONY: fpga

fpga: setup $(DTREE_DIR)
	make -C $(FPGA_DIR)

################################################################################
# U-Boot build provides: $(UBOOT)
################################################################################

ENVTOOLS_CFG    = $(INSTALL_DIR)/etc/fw_env.config

UBOOT_SCRIPT_BUILDROOT = $(srcdir)/patches/u-boot.script.buildroot
UBOOT_SCRIPT_DEBIAN    = $(srcdir)/patches/u-boot.script.debian
UBOOT_SCRIPT           = $(INSTALL_DIR)/u-boot.scr

.PHONY: u-boot

u-boot: $(UBOOT) $(UBOOT_SCRIPT) $(ENVTOOLS_CFG)

$(UBOOT_TAR): | $(DL)
	curl -L $(UBOOT_URL) -o $@

$(UBOOT_DIR): $(UBOOT_TAR)
	mkdir -p $@
	tar -zxf $< --strip-components=1 --directory=$@
	patch -d $@ -p 1 < $(top_srcdir)/patches/u-boot-xlnx-$(UBOOT_TAG).patch

$(UBOOT): $(UBOOT_DIR)
	mkdir -p $(@D)
	make -C $< arch=ARM zynq_red_pitaya_defconfig
	make -C $< arch=ARM CFLAGS=$(UBOOT_CFLAGS) PATH="${PATH}:${TOOLCHAIN_DIR}" CROSS_COMPILE=${CROSS_COMPILE} all
	cp $</u-boot $@

$(UBOOT_SCRIPT): $(INSTALL_DIR) $(UBOOT_DIR) $(UBOOT_SCRIPT_BUILDROOT) $(UBOOT_SCRIPT_DEBIAN)
	$(UBOOT_DIR)/tools/mkimage -A ARM -O linux -T script -C none -a 0 -e 0 -n "boot Buildroot" -d $(UBOOT_SCRIPT_BUILDROOT) $@.buildroot
	$(UBOOT_DIR)/tools/mkimage -A ARM -O linux -T script -C none -a 0 -e 0 -n "boot Debian"    -d $(UBOOT_SCRIPT_DEBIAN)    $@.debian
	cp $@.debian $@

$(ENVTOOLS_CFG): $(UBOOT_DIR)
	mkdir -p $(INSTALL_DIR)/etc/
	cp $</tools/env/fw_env.config $(INSTALL_DIR)/etc


################################################################################
# Linux build provides: $(LINUX)
################################################################################

.PHONY: linux
linux: $(LINUX)

$(LINUX_TAR): | $(DL)
	curl -L $(LINUX_URL) -o $@

$(LINUX_DIR): $(LINUX_TAR)
	mkdir -p $@
	tar -zxf $< --strip-components=1 --directory=$@
	patch -d $@ -p 1 < $(top_srcdir)/patches/linux-xlnx-$(LINUX_TAG)-config.patch
	patch -d $@ -p 1 < $(top_srcdir)/patches/linux-xlnx-$(LINUX_TAG)-eeprom.patch
	patch -d $@ -p 1 < $(top_srcdir)/patches/linux-xlnx-$(LINUX_TAG)-lantiq.patch
	patch -d $@ -p 1 < $(top_srcdir)/patches/linux-xlnx-$(LINUX_TAG)-wifi.patch
	cp -r $(top_srcdir)/patches/rtl8192cu $@/drivers/net/wireless/
	cp -r $(top_srcdir)/patches/lantiq/*  $@/drivers/net/phy/

$(LINUX): $(LINUX_DIR)
	make -C $< mrproper
	make -C $< ARCH=arm xilinx_zynq_defconfig
	make -C $< ARCH=arm CFLAGS=$(LINUX_CFLAGS) -j $(MAKE_PROCESS) \
	           PATH="${PATH}:${TOOLCHAIN_DIR}" CROSS_COMPILE=${CROSS_COMPILE} \
		   UIMAGE_LOADADDR=0x8000 uImage
	make -C $< ARCH=arm CFLAGS=$(LINUX_CFLAGS) -j $(MAKE_PROCESS) \
	           PATH="${PATH}:${TOOLCHAIN_DIR}" CROSS_COMPILE=${CROSS_COMPILE} \
		   modules
	cp $</arch/arm/boot/uImage $@

# manual triggering kernel commands
linux-image: $(LINUX_DIR)
	make -C $(LINUX_DIR) ARCH=arm CFLAGS=$(LINUX_CFLAGS) -j $(MAKE_PROCESS) UIMAGE_LOADADDR=0x8000 uImage

linux-modules: $(LINUX_DIR)
	make -C $(LINUX_DIR) ARCH=arm CFLAGS=$(LINUX_CFLAGS) -j $(MAKE_PROCESS) modules

menuconfig: $(LINUX_DIR)
	make -C $(LINUX_DIR) ARCH=arm CFLAGS=$(LINUX_CFLAGS) -j $(MAKE_PROCESS) menuconfig



################################################################################
# device tree processing
# TODO: here separate device trees should be provided for Ubuntu and buildroot
################################################################################

.PHONY:
devicetree: $(DEVICETREE)


$(DTREE_TAR): | $(DL)
	curl -L $(DTREE_URL) -o $@

$(DTREE_DIR): $(DTREE_TAR)
	mkdir -p $@
	tar -zxf $< --strip-components=1 --directory=$@

$(DEVICETREE): $(DTREE_DIR) $(LINUX) fpga
	cp $(DTS) $(TMP)/devicetree.dts
#	patch $(TMP)/devicetree.dts $(srcdir)/patches/devicetree.patch
	$(LINUX_DIR)/scripts/dtc/dtc -I dts -O dtb -o $(DEVICETREE) -i $(FPGA_DIR)/sdk/dts/ $(TMP)/devicetree.dts



################################################################################
# boot file generator
################################################################################

$(BOOT_UBOOT): fpga $(UBOOT)
	@echo img:{[bootloader] $(FSBL) $(FPGA) $(UBOOT) } > boot_uboot.bif
	bootgen -image boot_uboot.bif -w -o $@

################################################################################
# root file system
################################################################################

URAMDISK_DIR    = OS/buildroot

.PHONY: buildroot

$(INSTALL_DIR):
	mkdir $(INSTALL_DIR)

buildroot: $(INSTALL_DIR)
	$(MAKE) -C $(URAMDISK_DIR)
	$(MAKE) -C $(URAMDISK_DIR) install INSTALL_DIR=$(INSTALL_DIR)







################################################################################
#
################################################################################

clean:
	-make -C $(LINUX_DIR) clean
	make -C $(FPGA_DIR) clean
	-make -C $(UBOOT_DIR) clean
	$(RM) $(INSTALL_DIR) -rf
	$(RM) $(TARGET) -rf	
	$(RM) $(NAME)*.zip

