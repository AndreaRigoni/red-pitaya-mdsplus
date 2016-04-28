include $(top_srcdir)/Common.am

# Where to get buildroot & which version
B_SERVER=http://buildroot.uclibc.org/downloads
B_VERSION=$(BUILDROOT_TAG)
B_DIR=$(builddir)/buildroot-$(B_VERSION)
B_ARCHIVE=$(B_DIR).tar.gz
B_DOWNLOAD=$(B_SERVER)/$(B_ARCHIVE)
UIMAGE=$(B_DIR)/output/images/rootfs.cpio.uboot

INSTALL_DIR ?= $(builddir)
VERSION     ?= 0.00-0000
REVISION    ?= devbuild

export buildroot_srcdir=$(abs_top_srcdir)/OS/buildroot

all: $(UIMAGE)

# HF
TOOLCHAIN_PATH ?= /opt/linaro/gcc-linaro-4.9-2014.11-x86_64_arm-linux-gnueabihf
export TOOLCHAIN_PATH
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
