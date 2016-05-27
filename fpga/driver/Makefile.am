# Main GCC executable (used for compiling and linking)

include $(top_srcdir)/Common.am
# include ${abs_top_srcdir}/fpga/driver/Kbuild

obj = $(builddir)
src = $(srcdir)




modules: axidmatest_core.c dtbtrybind_core.c axidma_golden.c Kbuild
	-cp $^ .
	make $(AM_MAKEFLAGS) -C ${LINUX_DIR} ARCH=arm CFLAGS=$(LINUX_CFLAGS) -j $(MAKE_PROCESS) \
	PATH="${PATH}:${TOOLCHAIN_DIR}" CROSS_COMPILE=${CROSS_COMPILE} \
	M=`pwd` modules

all: modules

clean:
	rm  -f Kbuild          axidma_golden.c      axidma_golden.mod.o  \
	    axidmatest.mod.c  axidmatest_core.c  dtbtrybind.mod.c  \
	    dtbtrybind_core.c  modules.order \
	 axidma_golden.ko     axidma_golden.o      axidmatest.mod.o  \
	 axidmatest_core.o  dtbtrybind.mod.o  dtbtrybind_core.o \
	 Module.symvers  axidma_golden.mod.c  axidmatest.ko        \
	 axidmatest.o      dtbtrybind.ko      dtbtrybind.o 
