#
# $Id: Makefile 1283 2014-03-01 12:01:39Z ales.bardorfer $
#
# Red Pitaya Ramdisk (root filesystem) Makefile
#

# Where to get buildroot & which version
B_SERVER=http://buildroot.uclibc.org/downloads
B_VERSION=2014.02
B_DIR=$(builddir)/buildroot-$(B_VERSION)
B_ARCHIVE=$(B_DIR).tar.gz
B_DOWNLOAD=$(B_SERVER)/$(B_ARCHIVE)
UIMAGE=$(B_DIR)/output/images/rootfs.cpio.uboot

INSTALL_DIR ?= $(builddir)
VERSION     ?= 0.00-0000
REVISION    ?= devbuild

export buildroot_srcdir=$(srcdir)

all: $(UIMAGE)

# HF
TOOLCHAIN_PATH=/opt/linaro/gcc-linaro-4.9-2014.11-x86_64_arm-linux-gnueabihf
$(B_DIR)/.config: $(srcdir)/config_${B_VERSION}.armhf
	cp $< $@



$(UIMAGE): $(B_DIR) overlay $(B_DIR)/.config
	$(MAKE) -C $(B_DIR) USER_HOOKS_EXTRA_ENV='VERSION=$(VERSION) REVISION=$(REVISION)'

$(B_DIR):
	wget $(B_DOWNLOAD)
	tar xfz $(B_ARCHIVE)


download: $(B_DIR)

install: $(UIMAGE)
	mkdir -p $(INSTALL_DIR)
	cp $(UIMAGE) $(INSTALL_DIR)/uramdisk.image.gz

config nconfig xconfig gconfig: $(B_DIR) overlay
	-$(MAKE) $(B_DIR)/.config
	-$(MAKE) -C $(B_DIR) $@



clean:
	-$(MAKE) -C $(B_DIR) clean
	rm *~ -f

mrproper:
	-rm -rf $(B_DIR) $(B_ARCHIVE)
	-rm *~ -f
