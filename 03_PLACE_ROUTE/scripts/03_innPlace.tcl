#######################
## Load floorplan dB ##
#######################
source ../scripts/innoGlobal.tcl
source ../data/floorplan.inn

set 99_dir ../../99_SRC
set cpfloc $99_dir/cpf/aes_chip.cpf
set hdl_dir $99_dir/src/hdl


##########################
## Setup Timing options ##
##########################
set_analysis_view -setup {AV_on_mode_wc_rc125_setup} -hold {AV_on_mode_bc_rc0_hold}
setAnalysisMode -analysisType onChipVariation -cppr both -checkType setup

#####################
## Timing Derating ##
#####################
source ../scripts/innoTimingDerate.tcl

######################
## Place the Design ##
######################
placeDesign -inPlaceOpt
#place_opt_design
getTieHiLoMode
addTieHiLo -cell "LOGIC1_X1 LOGIC0_X1" -powerDomain TOP
addTieHiLo -cell "LOGIC1_X1 LOGIC0_X1" -powerDomain AES_PSO

###################
## Report Timing ##
###################
timeDesign -preCTS -outDir ../reports/place -prefix timing
timeDesign -preCTS -expandedViews -numPaths 10 -outDir ../reports/place -prefix timingExp
#timeDesign -preCTS -numPaths 10 -outDir timingReports/place -prefix place

#################
## Save Design ##
#################
clearDrc
foreach mode [ all_constraint_modes ] {
    eval "update_constraint_mode -name $mode -sdc \"[ get_constraint_mode  $mode -sdc_files ]\""
}
saveDesign ../data/placement.inn


#exit
