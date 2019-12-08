#######################
## Load floorplan dB ##
#######################
source ../data/route.inn
source ../scripts/innoGlobal.tcl

set 99_dir ../../99_SRC
set cpfloc $99_dir/cpf/aes_chip.cpf
set hdl_dir $99_dir/src/hdl


##########################
## Setup Timing options ##
##########################
set_analysis_view \
-setup {AV_on_mode_wc_rc125_setup AV_sleep_mode_wc_rc125_setup} \
-hold {AV_sleep_mode_bc_rc0_hold AV_on_mode_bc_rc0_hold}

#####################
## Timing Derating ##
#####################
source ../scripts/innoTimingDerate.tcl
set_interactive_constraint_modes [ all_constraint_modes -active ]
set_propagated_clock [ all_clocks ]
setAnalysisMode -analysisType onChipVariation -cppr both -checkType setup

createBasicPathGroups
get_path_groups *

setDelayCalMode -reset
setDelayCalMode -engine Aae -SIAware true
setDelayCalMode -equivalent_waveform_model_type ecsm -equivalent_waveform_model_propagation true


#################
## SI settings ##
#################
setSIMode -reset
setSIMode -analysisType aae
setSIMode -detailedReports false
setSIMode -separate_delta_delay_on_data true
setSIMode -delta_delay_annotation_mode lumpedOnNet
setSIMode -num_si_iteration 3
setSIMode -enable_glitch_report true


#####################
## Routing options ##
#####################
setNanoRouteMode -quiet -routeInsertAntennaDiode true
setNanoRouteMode -quiet -routeAntennaCellName "ANTENNA_X1"
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -quiet -routeWithSiDriven true

#############################
## Remove Std Filler Cells ##
#############################
setFillerMode -doDRC false -corePrefix FILL -core "FILLCELL_X32 FILLCELL_X16 FILLCELL_X8 FILLCELL_X4 FILLCELL_X2 FILLCELL_X1"
deleteFiller


#############################
## Post Route Optimization ##
#############################
# Allow the usage of LVT cells for final setup fixing
#set_dont_use [get_lib_cells *LVT] false
# Allow the usage of Delay Cells for hold fixing
#set_dont_use   [get_lib_cells */DLY*] false
#set_dont_touch [get_lib_cells */DLY*] false
## Fix Setup and Hold ##
optDesign -postRoute -setup -hold -outDir ../reports/optroute -prefix optRouteSetupHold -expandedViews

##################################
## Post Route HOLD Optimization ##
##################################
#Is the hold clean ? If not an incremental fix can be usefull:
setOptMode -holdTargetSlack 0.075
setOptMode -fixHoldAllowSetupTnsDegrade false
optDesign -postRoute -hold -outDir ../reports/optroute -prefix optRouteHoldIncr -expandedViews


#############################
## Insert Std Filler Cells ##
#############################
addFiller

############################
## Final Timing Reporting ##
############################
timeDesign -postRoute -outDir ../reports/optroute -prefix optRouteSetupFinal -expandedViews
timeDesign -postRoute -hold -outDir ../reports/optroute -prefix optRouteHoldFinal -expandedViews

########################################
## Export def file for QRC Extraction ##
########################################
defOut -floorplan -placement -netlist -routing ../data/optRoute.def.gz
saveNetlist ../data/optRoute.v -excludeLeafCell
saveNetlist ../data/optRoute.phys.v -excludeLeafCell -phys

#################
## Save Design ##
#################
foreach mode [ all_constraint_modes ] {
    eval "update_constraint_mode -name $mode -sdc \"[ get_constraint_mode  $mode -sdc_files ]\""
}
saveDesign ../data/optroute.inn

#exit
