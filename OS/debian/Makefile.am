
include $(top_srcdir)/Common.am

OVERLAY = $(srcdir)/overlay
IMAGE   = debian_armhf.img

export srcdir
export top_srcdir

export IMAGE
export OVERLAY
export ECOSYSTEM_ZIP

.PHONY: mount-image
mount-image: image.sh $(IMAGE)
	@echo "mount sd card image"
	@. $< mount_image

.PHONY: umount-image
umount-image: image.sh $(IMAGE)
	@echo "mount sd card image"
	@. $< umount_image


.PHONY: image
image: $(IMAGE)

$(IMAGE): image.sh
	@echo "building sd card image"
	-@. $< install_debian
	-@. $< install_ecosystem
	-@. $< umount_image


all: image
