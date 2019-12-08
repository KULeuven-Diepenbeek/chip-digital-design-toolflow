##############
## Settings ##
##############
tclmode

set 99_dir ../../99_SRC
set cpfloc $99_dir/cpf/aes_chip.cpf

set_case_sensitivity on
set_lowpower_option -netlist_style physical
#LLibrary related
#vpx set rule handling CPF_LIB8 -Ignore
#vpx set rule handling CPF_LIB9 -Ignore
##JV: ignore following rules as some inputs are tied to ground
#vpx set rule handling PDM2d -Ignore
##JV: ignore following rules as SI inputs of ret flops are floating
#vpx set rule handling CLP_STRC2 -Ignore

###################
## Library Setup ##
###################
# Reading power and ground pins from LEF
read_lef_file \
/tech/NangateOpenCell/Back_End/lef/NangateOpenCellLibrary.macro.lef \
/tech/NangateOpenCell/Back_End/lef/NangateOpenCellLibrary.tech.lef \
/tech/NangateOpenCell/Back_End/lef/NangateOpenCellLibrary.macro.lef \
/tech/NangateOpenCell/Low_Power/Back_End/lef/LowPowerOpenCellLibrary.tech.lef \
/tech/NangateOpenCell/Low_Power/Back_End/lef/LowPowerOpenCellLibrary.macro.lef \

read_library -extract_liberty_pg_pin -cpf $cpfloc

##################
## Design Setup ##
##################
read_design -verilog -sensitive ../../04_PLACE_ROUTE/data/optRoute.v
#report_floating_signals > ./reports/float.rpt
#report_tied_signals > ./reports/tied.rpt

##################
## Power Intent ##
################
read_power_intent -post_route -cpf $cpfloc
commit_power_intent
analyze_power_domain
report_rule_check -verbose > ../reports/struct_check_summary.rpt
write_rule_check -replace ../reports/struct_check_full.rpt

#exit
