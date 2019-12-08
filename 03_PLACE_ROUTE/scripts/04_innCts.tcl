#######################
## Load floorplan dB ##
#######################
set 99_dir ../../99_SRC
set cpfloc $99_dir/cpf/aes_chip.cpf
set hdl_dir $99_dir/src/hdl

source ../scripts/innoGlobal.tcl
source ../data/placement.inn


##########################
## Setup Timing options ##
##########################
set_analysis_view -setup {AV_on_mode_wc_rc125_setup} -hold {AV_on_mode_bc_rc0_hold}
setAnalysisMode -analysisType onChipVariation -cppr both -checkType setup

#####################
## Timing Derating ##
#####################
source ../scripts/innoTimingDerate.tcl

#########################
## ClockTree Synthesis ##
#########################
cleanupSpecifyClockTree
source $99_dir/cts/my_ctsSpec_ccopt.tcl
create_ccopt_clock_tree_spec -views {AV_on_mode_wc_rc125_setup AV_on_mode_bc_rc0_hold } -file ../data/cts/ctsSpec_ccopt.tcl
source ../data/cts/ctsSpec_ccopt.tcl
ccopt_design

###################
## Report Timing ##
###################
timeDesign -postCTS -numPaths 10 -outDir ../reports/cts
timeDesign -postCTS -hold -numPaths 10 -outDir ../reports/cts


#################
## Save Design ##
#################
foreach mode [ all_constraint_modes ] {
    eval "update_constraint_mode -name $mode -sdc \"[ get_constraint_mode  $mode -sdc_files ]\""
}
saveDesign ../data/cts.inn

#exit
