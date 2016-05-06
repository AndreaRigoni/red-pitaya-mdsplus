# Main GCC executable (used for compiling and linking)

include $(top_srcdir)/Common.am
# include ${abs_top_srcdir}/fpga/driver/Kbuild

obj = $(builddir)
src = $(srcdir)

axidmatest: axidmatest.c Kbuild
	-cp $^ .
	make $(AM_MAKEFLAGS) -C ${LINUX_DIR} ARCH=arm CFLAGS=$(LINUX_CFLAGS) -j $(MAKE_PROCESS) \
	PATH="${PATH}:${TOOLCHAIN_DIR}" CROSS_COMPILE=${CROSS_COMPILE} \
	M=`pwd` modules

