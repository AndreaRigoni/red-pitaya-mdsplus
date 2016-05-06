# Main GCC executable (used for compiling and linking)
CC=$(CROSS_COMPILE)gcc
# Installation directory
INSTALL_DIR ?= .


TMP = ../../tmp

UBOOT_TAG     = xilinx-v2015.4
LINUX_TAG     = xilinx-v2015.4.01
DTREE_TAG     = xilinx-v2015.4
#BUILDROOT_TAG = 2015.5

UBOOT_DIR     = $(TMP)/u-boot-xlnx-$(UBOOT_TAG)
LINUX_DIR     = $(TMP)/linux-xlnx-$(LINUX_TAG)
DTREE_DIR     = $(TMP)/device-tree-xlnx-$(DTREE_TAG)
BUILDROOT_DIR = $(TMP)/buildroot-$(BUILDROOT_TAG)

SYSROOT=../../OS/buildroot/buildroot-2014.02/output/host/usr/arm-buildroot-linux-gnueabihf/sysroot
LINUX_CFLAGS = "-O2 -mtune=cortex-a9 -mfpu=neon -mfloat-abi=hard"
UBOOT_CFLAGS = "-O2 -mtune=cortex-a9 -mfpu=neon -mfloat-abi=hard"



obj-m += axidmatest.o

axidmatest: axidmatest.c
	make -C ${LINUX_DIR} ARCH=arm CFLAGS=$(LINUX_CFLAGS) -j $(shell grep -c ^processor /proc/cpuinfo) M=$(PWD) modules


