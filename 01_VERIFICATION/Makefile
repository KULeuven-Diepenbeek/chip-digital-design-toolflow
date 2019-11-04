#=======================================================================
# Makefile for HDL simulation with Cadence Incisive
#-----------------------------------------------------------------------


default: all

base_dir = $(abspath ..)
src_dir = $(abspath ../99_SRC/hdl)
test_dir = $(abspath ../99_SRC/tb)
test_bench = CHIP_tb

# define the simulator
simulator = irun
# define simulator options
simulator_flags = -access +rwc -v93 -smartorder

sim_dir = .

rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

all: getfiles sim

debug: getfiles sim-debug

getfiles:
	@> file_list
	@echo "Preparing file list..."
ifneq ("$(call rwildcard,$(src_dir),*.vhd)", "")
	@find $(src_dir) -type f -name "*.vhd" -printf "%p " >> file_list
endif
ifneq ("$(call rwildcard,$(test_dir),*.vhd)", "")
	@find $(test_dir) -type f -name "*.vhd" -printf "%p " >> file_list
endif
ifneq ("$(call rwildcard,$(src_dir),*.v)", "")
	@find $(src_dir) -type f -name "*.v" -printf "%p " >> file_list
endif
ifneq ("$(call rwildcard,$(test_dir),*.v)", "")
	@find $(test_dir) -type f -name "*.v" -printf "%p " >> file_list
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
