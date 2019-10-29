#=======================================================================
# Makefile for HDL simulation with Cadence Incisive
#-----------------------------------------------------------------------


default: all

base_dir = $(abspath ..)
src_dir = $(abspath ../99_SRC/hdl)
test_dir = $(abspath ../99_SRC/tb)
test_bench = AES128_tb

verilog = FALSE
vhdl = TRUE

# Direct this path to a directory that has "unlimited" disk space
# Typically this would be a temp dir on the machine you are using
# This should match the vcd_dump_dir variable defined in the setup.tcl in the 04_POWER section!!!!!
vcd_dump_dir = /tmp/no_backup

# define the simulator
simulator = irun
# define simulator options
simulator_flags = -access +rwc -v93 -smartorder

sim_dir = .

all: getfiles sim

debug: getfiles sim-debug

getfiles:
	@> file_list
	@echo "Preparing file list..."
ifneq ("$(wildcard $(src_dir)/*.vhd)", "")
	@echo -n $(src_dir)/*.vhd >> file_list
	@echo -n " " >> file_list
endif
ifneq ("$(wildcard $(test_dir)/*.vhd)", "")
	@echo -n $(test_dir)/*.vhd >> file_list
	@echo -n " " >> file_list
endif
ifneq ("$(wildcard $(src_dir)/*.v)", "")
	@echo -n $(src_dir)/*.v >> file_list
	@echo -n " " >> file_list
endif
ifneq ("$(wildcard $(test_dir)/*.v)", "")
	@echo -n $(test_dir)/*.v >> file_list
	@echo -n " " >> file_list
endif

# Run the simulation file
sim:
	$(simulator) `cat file_list` -top $(test_bench) $(simulator_flags)

sim-debug:
	$(simulator) `cat file_list` -top $(test_bench) $(simulator_flags) -gui




#------------------------------------------------------------
# Clean up

clean:
	rm -rf irun.* file_list .simvision INCA_libs waves.shm simvision*
