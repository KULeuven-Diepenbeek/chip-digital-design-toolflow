##############
## Settings ##
##############

tclmode

set 99_dir ../../99_SRC
set cpfloc $99_dir/cpf/aes_chip.cpf

set_case_sensitivity on
set_lowpower_option -netlist_style logical
#Ignore identify_always_on_driver for RTL
#vpx set rule handling CPF_DES10 -Ignore
#vpx set rule handling CPF_LIB41 -Ignore

###################
## Library Setup ##
###################
#LEF needed for power pin definition
read_lef_file \
/tech/NangateOpenCell/Back_End/lef/NangateOpenCellLibrary.macro.lef \
/tech/NangateOpenCell/Back_End/lef/NangateOpenCellLibrary.tech.lef \
/tech/NangateOpenCell/Back_End/lef/NangateOpenCellLibrary.macro.lef \
/tech/NangateOpenCell/Low_Power/Back_End/lef/LowPowerOpenCellLibrary.tech.lef \
/tech/NangateOpenCell/Low_Power/Back_End/lef/LowPowerOpenCellLibrary.macro.lef \

read_library -cpf $cpfloc

##################
## Design Setup ##
##################
#read_design -verilog2k -noelab \ */

set hdl_dir $99_dir/src/hdl

read_design -VHDL -noelab \
$hdl_dir/aes128/bytesub.vhd \
$hdl_dir/aes128/mixcolumn.vhd \
$hdl_dir/aes128/shiftrow.vhd \
$hdl_dir/aes128/keyscheduler.vhd \
$hdl_dir/aes128/aes_top.vhd \
$hdl_dir/uart/uart_RX.vhd \
$hdl_dir/uart/uart_TX.vhd \
$hdl_dir/uart/uart_Core.vhd \
$hdl_dir/uart/fifo_fallthrough.vhd \
$hdl_dir/uart/completeUART.vhd \
$hdl_dir/chip.vhd
elaborate_design -root AES_CHIP

report_floating_signals > ./reports/float.rpt
report_tied_signals > ./reports/tied.rpt

#########################
## Power Intent Checks ##
#########################
read_power_intent -pre_synthesis -cpf $cpfloc

#commit_power_intent -insert_isolation -functional_insertion

commit_power_intent -functional_insertion
analyze_power_domain

#exit
