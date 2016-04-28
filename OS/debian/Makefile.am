
include $(top_srcdir)/Common.am

export srcdir
export top_srcdir

export IMAGE=debian_armhf.img
export OVERLAY=${srcdir}/overlay
export ECOSYSTEM_ZIP

.PHONY: image
image: $(srcdir)/image.sh
	@echo "building sd card image"
	@. $< install_debian
	@. $< install_ecosystem


all: image
