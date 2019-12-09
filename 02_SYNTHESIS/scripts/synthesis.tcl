#############################
## Read libraries from CPF ##
#############################
set chip_top AES_CHIP
set 99_dir ../../99_SRC
set cpfloc $99_dir/cpf/aes_chip.cpf
set hdl_dir $99_dir/src/hdl

read_power_intent -cpf  -module AES_CHIP $cpfloc
check_library

set_attribute lef_library { \
  /tech/NangateOpenCell/Back_End/lef/NangateOpenCellLibrary.tech.lef \
  /tech/NangateOpenCell/Back_End/lef/NangateOpenCellLibrary.macro.lef \
  /tech/NangateOpenCell/Low_Power/Back_End/lef/LowPowerOpenCellLibrary.tech.lef \
  /tech/NangateOpenCell/Low_Power/Back_End/lef/LowPowerOpenCellLibrary.macro.lef \
}


####################
## Read RTL files ##
####################

set_attribute hdl_search_path $hdl_dir /
read_hdl -vhdl { \
./aes128/bytesub.vhd \
./aes128/mixcolumn.vhd \
./aes128/shiftrow.vhd \
./aes128/keyscheduler.vhd \
./aes128/aes_top.vhd \
./uart/uart_RX.vhd \
./uart/uart_TX.vhd \
./uart/uart_Core.vhd \
./uart/fifo_fallthrough.vhd \
./uart/completeUART.vhd \
./chip.vhd
}

###########################
## Enabling Clock Gating ##
###########################
set_attribute lp_insert_clock_gating true /

##########################
## Elaborate the design ##
##########################
set_attribute hdl_error_on_latch true
set_attribute hdl_undriven_signal_value 0

# Set don't use scan flipflops
set_attribute preserve true SDFF*
set_attribute avoid true SDFF*

elaborate $chip_top

#########################
## Uniquify the design ##
#########################
uniquify /designs/$chip_top -verbose
# ungroup -flatten -all

##############################
## Define Clock Gating cell ##
##############################
set_attribute lp_clock_gating_cell [lindex [find / -libcell CLKGATE_X4] 0] /designs/$chip_top

###############################
## Define switching activity ##
###############################
set_attribute lp_toggle_rate_unit /ns /
set_attribute lp_power_analysis_effort high /
set_attribute lp_asserted_probability 0.35 [find -port clock]
set_attribute lp_asserted_toggle_rate 0.5 [find -port clock]
#set_attribute lp_asserted_probability 0.5 [find -port "ports_in/rclk"]
#set_attribute lp_asserted_toggle_rate 0.666666667 [find -port "ports_in/rclk"]
#get_attribute lp_computed_toggle_rate [find -port "ports_in/rclk"]

#################################
## Power Optimization settings ##
#################################
set_attribute leakage_power_effort medium /
set_attribute lp_power_optimization_weight 0.95 /designs/$chip_top

###############
## Apply CPF ##
###############
apply_power_intent

################
## Commit CPF ##
################
#report low_power_cells -summary
commit_power_intent -design $chip_top
report low_power_cells -summary > ../reports/$chip_top.lowpowercells.rpt

##############################
## Synthesis to Nangate lib ##
##############################
#set_attribute information_level 2
set_attribute syn_map_effort express
# syn_generic $chip_top
syn_map $chip_top

report timing -summary
report power -detail > ../reports/$chip_top.power.BeforeOpt.rpt


##############################
## Incremental optimization ##
##############################
report power
set_attribute syn_opt_effort high
syn_opt $chip_top -incremental

report timing -summary
report power -detail > ../reports/$chip_top.power.AfterOpt.rpt

####################
## Some Reporting ##
####################
report messages -all > ../reports/$chip_top.messages.rpt
report timing -encounter -worst 10 >  ../reports/$chip_top.timing.rpt
report datapath -all > ../reports/$chip_top.datapath.rpt
report gates -power > ../reports/$chip_top.gates.rpt
report low_power_cells > ../reports/$chip_top.lp_cells.rpt
report qor -levels_of_logic > ../reports/$chip_top.qor.rpt
report sequential > ../reports/$chip_top.sequential.rpt
# Any instance in the design can be specified
#report instance -timing -power $chip_top > ../reports/$chip_top.instance.rpt
#set_db $chip_top .library_domain typ_0500
report area > ../reports/$chip_top.area.rpt
report gates > ../reports/$chip_top.gates.rpt
report power -hier >  ../reports/$chip_top.power.rpt

#sizeof_collection  [get_cells * -filter "ref_lib_cell_name !~ *HVT" -hierarchical -quiet]
#sizeof_collection  [get_cells * -filter "ref_lib_cell_name =~ *HVT" -hierarchical -quiet]

###############################
## Write out verilog netlist ##
###############################

write_hdl > ../data/$chip_top.synthesis.v
write_sdf > ../data/$chip_top.synthesis.sdf


puts "INFO: Reached end of synthesis"

exit

# ------------------------------------------------------------------------------
# End of File
# ------------------------------------------------------------------------------
