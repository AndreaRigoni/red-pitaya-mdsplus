
include $(top_srcdir)/Common.am

OVERLAY = $(srcdir)/overlay
IMAGE   = debian_armhf.img

export srcdir
export top_srcdir

export IMAGE
export OVERLAY
export ECOSYSTEM_ZIP

.PHONY: image
image: $(srcdir)/image.sh
	@echo "building sd card image"
	-@. $< install_debian
	-@. $< install_ecosystem
	-@. $< umount_image


all: image
