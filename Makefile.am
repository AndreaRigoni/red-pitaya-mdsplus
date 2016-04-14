SUBDIRS =
if BUILD_MDSPLUS
SUBDIRS += mdsplus
endif
SUBDIRS += src

ACLOCAL_AMFLAGS = -I m4
include Common.am


.PHONY: mdsplus
mdsplus:
	@ echo "Building mdsplus submodule"
if BUILD_MDSPLUS
	@ $(MAKE) -C mdsplus all
endif

