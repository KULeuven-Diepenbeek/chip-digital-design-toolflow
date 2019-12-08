tclmode

set 99_dir ../../99_SRC
set cpfloc $99_dir/cpf/aes_chip.cpf

set_case_sensitivity on
set_lowpower_option -auto -golden CPF -revised PHYSICAL

read_lef_file \
/tech/NangateOpenCell/Back_End/lef/NangateOpenCellLibrary.macro.lef \
/tech/NangateOpenCell/Back_End/lef/NangateOpenCellLibrary.tech.lef \
/tech/NangateOpenCell/Back_End/lef/NangateOpenCellLibrary.macro.lef \
/tech/NangateOpenCell/Low_Power/Back_End/lef/LowPowerOpenCellLibrary.tech.lef \
/tech/NangateOpenCell/Low_Power/Back_End/lef/LowPowerOpenCellLibrary.macro.lef \

read_library -extract_liberty_pg_pin -cpf $cpfloc

## Set undefined cells as BlackBox
#vpx set undefined cell Black_box -both

read_design -verilog -golden -sensitive ../../02_SYNTHESIS/data/AES_CHIP.synthesis.v

#! Error when reading .phys.v because pg_pin not define in some ecsm.lib file, only in Coarse Grain libs (*cg*)
#!// Error: HRC3.3: Undefined named port connection
#!//  Cannot find pin FE_PHC479_rs2_data_14_/VDD
#!//  (instance) on line 100 in file '../DesignDataOut/OptRoute.phys.v'
#!//  (module) on line 309394 in file '../Library/ecsm/tcbn65lphpbwpwc0d9_ecsm.lib'
read_design -verilog -revised -sensitive ../../04_PLACE_ROUTE/data/optRoute.v

#Read the CPF file
read_power_intent -cpf -both  $cpfloc

#Insert low power cells (virtual) to the golden netlist
commit_power_intent -gol -insert_isolation
commit_power_intent -rev


set_system_mode -map lec

report_unmapped_points > ../reports/lec.unmapped
report_mapped_points > ../reports/lec.mapped

report_mapped_points * -summary > ../reports/lec.mapped.sum

add_compared_points -all

compare

report_verification > ../reports/lec.verification
report_compare_data -class nonequivalent > ../reports/lec.noneq
report_floating_signals > ../reports/lec.float
report_tied_signals > ../reports/lec.tied

report_statistics > ../reports/lec.stats


#exit
