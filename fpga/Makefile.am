#
# Authors: Matej Oblak, Iztok Jeras
# (C) Red Pitaya 2013-2015
#
# Red Pitaya FPGA/SoC Makefile 
#
# Produces:
#   3. FPGA bit file.
#   1. FSBL (First stage bootloader) ELF binary.
#   2. Memtest (stand alone memory test) ELF binary.
#   4. Linux device tree source (dts).


include $(top_srcdir)/Common.am

# build artefacts
FPGA_BIT=out/red_pitaya.bit
FSBL_ELF=sdk/fsbl/executable.elf
DEVICE_TREE=sdk/dts/system.dts

export srcdir
export maxThreads=$(MAKE_PROCESS)

# Vivado from Xilinx provides IP handling, FPGA compilation
# hsi (hardware software interface) provides software integration
# both tools are run in batch mode with an option to avoid log/journal files
VIVADO = vivado -nolog -nojournal -mode batch
HSI    = hsi    -nolog -nojournal -mode batch

.PHONY: all clean project fpga bit fsbl dts

all: $(FPGA_BIT) $(FSBL_ELF) $(DEVICE_TREE)

clean:
	-rm -rf out .Xil .srcs sdk
	
project:
	vivado -source $(srcdir)/red_pitaya_vivado_project.tcl

clean_project:
	-rm -rf project  vivado.jou  vivado.log  vivado_*.backup.jou  vivado_*.backup.log  vivado_pid*.str

update_project:
	cp -a $(builddir)/project/system.tcl $(srcdir)/ip/system.tcl

fpga bit: $(FPGA_BIT)

$(FPGA_BIT):
	$(VIVADO) -source $(srcdir)/red_pitaya_vivado.tcl

fsbl: $(FSBL_ELF)

$(FSBL_ELF): $(FPGA_BIT)
	$(HSI) -source $(srcdir)/red_pitaya_hsi_fsbl.tcl

dts: $(DEVICE_TREE)

$(DEVICE_TREE): $(FPGA_BIT)
	$(HSI) -source $(srcdir)/red_pitaya_hsi_dts.tcl

