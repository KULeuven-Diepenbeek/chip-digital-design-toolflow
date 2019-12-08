#######################
## Load floorplan dB ##
#######################
source ../data/floorplan.inn
source ../scripts/innoGlobal.tcl

set 99_dir ../../99_SRC
set cpfloc $99_dir/cpf/aes_chip.cpf
set hdl_dir $99_dir/src/hdl


##########################
## Setup Timing options ##
##########################
set_analysis_view -setup {AV_on_mode_wc_rc125_setup} -hold {AV_on_mode_bc_rc0_hold}
setAnalysisMode -analysisType onChipVariation -cppr both -checkType setup

####################
## Fast Placement ##
####################
setPlaceMode -fp true
placeDesign -noPrePlaceOpt
refinePlace
fit
clearDrc


###########################################
## Pre Rail Analysis Structural Analysis ##
###########################################
verifyGeometry
#verifyConnectivity -noAntenna -noUnroutedNet
verifyPowerVia


####################
## Power Analysis ##
####################
set_power_analysis_mode -method static -analysis_view AV_on_mode_wc_rc125_setup \
	-corner max -create_binary_db true -write_static_currents true -honor_negative_energy true -ignore_control_signals true
set_power_output_dir ../reports/power_analysis
set_default_switching_activity -input_activity 0.75 -period 3.0 -global_activity 0.75
report_power -rail_analysis_format VS -outfile ../reports/power_analysis/aes_chip_power.rpt


#exit
