##############
## Settings ##
##############
tclmode

set 99_dir ../../99_SRC
set cpfloc $99_dir/cpf/aes_chip.cpf

set_case_sensitivity on
set_lowpower_option -netlist_style logical
#Ignore following rules as SI inputs of ret flops are floating
#vpx set rule handling CLP_STRC2 -Ignore
#Ignore identify_always_on_driver for RTL
vpx set rule handling CPF_DES10 -Ignore
#Ignore libraries pin definition mismatch
#vpx set rule handling CPF_LIB17 -Ignore

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
read_design -verilog -sensitive ../data/AES_CHIP.synthesis.v

report_floating_signals > ../reports/float.rpt
report_tied_signals > ../reports/tied.rpt

##########################
## Power Intent Checks ##
##########################
read_power_intent -pre_route -cpf $cpfloc
commit_power_intent
analyze_power_domain

report_rule_check -verbose > ../reports/struct_check_summary.rpt
write_rule_check -replace ../reports/struct_check_full.rpt

#exit
