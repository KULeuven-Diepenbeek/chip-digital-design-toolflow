#######################
## Load floorplan dB ##
#######################
source ../data/cts.inn
source ../scripts/innoGlobal.tcl

set 99_dir ../../99_SRC
set cpfloc $99_dir/cpf/aes_chip.cpf
set hdl_dir $99_dir/src/hdl


##########################
## Setup Timing options ##
##########################
set_analysis_view -setup {AV_on_mode_wc_rc125_setup} -hold {AV_on_mode_bc_rc0_hold}
set_interactive_constraint_modes [ all_constraint_modes -active ]
set_propagated_clock [ all_clocks ]
setAnalysisMode -analysisType onChipVariation -cppr both -checkType setup

#####################
## Timing Derating ##
#####################
source ../scripts/innoTimingDerate.tcl

#############################
## Insert Std Filler Cells ##
#############################
setFillerMode -doDRC false -corePrefix FILL -core "FILLCELL_X32 FILLCELL_X16 FILLCELL_X8 FILLCELL_X4 FILLCELL_X2 FILLCELL_X1"
addFiller


#####################
## Routing options ##
#####################
setNanoRouteMode -routeWithSiDriven true
setNanoRouteMode -routeInsertAntennaDiode true
setNanoRouteMode -routeAntennaCellName "ANTENNA_X1"
## MANUAL TASK
##############
#?Enabling timing Driven Routing?
setNanoRouteMode -routeWithTimingDriven true

########################################
## Secondary power pins power routing ##
########################################
setPGPinUseSignalRoute AON_BUF_X2:VDDBAK
routePGPinUseSignalRoute -nets {VDD VDDSW}


##################
## Route Design ##
##################
routeDesign

###################
## Report timing ##
###################
timeDesign -postRoute -numPaths 10 -outDir ../reports/route -prefix timing

########################################
## Export def file for QRC Extraction ##
########################################
defOut -floorplan -placement -netlist -routing ../data/route.def.gz

#################
## Save Design ##
#################
foreach mode [ all_constraint_modes ] {
    eval "update_constraint_mode -name $mode -sdc \"[ get_constraint_mode  $mode -sdc_files ]\""
}
saveDesign ../data/route.inn

#exit
