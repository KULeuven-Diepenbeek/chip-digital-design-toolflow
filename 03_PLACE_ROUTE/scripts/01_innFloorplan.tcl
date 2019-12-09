################################################
## Setup physical libraries and input netlist ##
################################################
source ../scripts/innoGlobal.tcl

set defHierChar /

set chip_top AES_CHIP

set 99_dir ../../99_SRC
set cpfloc $99_dir/cpf/aes_chip.cpf
set hdl_dir $99_dir/src/hdl


set init_cpf_file $cpfloc
set init_lef_file { \
/tech/NangateOpenCell/Back_End/lef/NangateOpenCellLibrary.tech.lef \
/tech/NangateOpenCell/Back_End/lef/NangateOpenCellLibrary.macro.lef \
/tech/NangateOpenCell/Low_Power/Back_End/lef/LowPowerOpenCellLibrary.tech.lef \
/tech/NangateOpenCell/Low_Power/Back_End/lef/LowPowerOpenCellLibrary.macro.lef \
}

set init_pwr_net {VDD VDDSW}
set init_gnd_net {VSS}
set init_top_cell $chip_top
set init_verilog ../../02_SYNTHESIS/data/$chip_top.synthesis.v

#################
## Read Design ##
#################
init_design

######################
## Create RC corner ##
######################
#create_rc_corner -name rc125 \
# -qx_tech_file ../Library/tech/qrc/RC_QRC_gpdk045/rctyp/qrcTechFile \
# -T 125
create_rc_corner -name rc125 -T 125
create_rc_corner -name rc0 -T 0

#create_rc_corner -name rc0 \
# -qx_tech_file ../Library/tech/qrc/RC_QRC_gpdk045/rctyp/qrcTechFile \
# -T 0

##########################
## Update Delay Corners ##
##########################
#Note: CPF syntax doesn't allow to define the extraction corner to be used for each Analysis View.
#We have to define this relationship through native encounter command
#Encounter will automatically create a delay_corner based on AV name => <AV_name>_dc
#We need to update this delay_corner with the extraction rc_corner we want
update_delay_corner -name AV_on_mode_wc_rc125_setup_dc -rc_corner rc125
update_delay_corner -name AV_sleep_mode_wc_rc125_setup_dc -rc_corner rc125
update_delay_corner -name AV_on_mode_wc_rc125_hold_dc -rc_corner rc125
update_delay_corner -name AV_sleep_mode_wc_rc125_hold_dc -rc_corner rc125
update_delay_corner -name AV_on_mode_bc_rc0_hold_dc -rc_corner rc0
update_delay_corner -name AV_sleep_mode_bc_rc0_hold_dc -rc_corner rc0

################################
## Select Active Timing Views ##
################################
set_analysis_view -setup {AV_on_mode_wc_rc125_setup} -hold {AV_on_mode_bc_rc0_hold}

#####################
## Timing Derating ##
#####################
source ../scripts/innoTimingDerate.tcl

#########################
## Adding SI Libraries ##
#########################
#update_library_set -name gpdk045_wc_hi_lib -si [ list ../Library/cdb/slow.cdb ]
#update_library_set -name gpdk045_wc_lo_lib -si [ list ../Library/cdb/slow.cdb ]
#update_library_set -name gpdk045_bc_hi_lib -si [ list ../Library/cdb/fast.cdb ]
#update_library_set -name gpdk045_bc_lo_lib -si [ list ../Library/cdb/fast.cdb ]

###########################
## Read Power Intent CPF ##
###########################
read_power_intent -cpf $cpfloc


#########################
## Commit Power Intent ##
#########################
commit_power_intent

###############################
## Floorplan initialization  ##
###############################
setPinConstraint -side {top bottom} -layer {M2}
setPinConstraint -side {right left} -layer {M3}
floorPlan -site FreePDK45_38x28_10R_NP_162NW_34O -s 350 350 30.0 30.0 30.0 30.0
loadIoFile $99_dir/io/$chip_top.io

################################################
## Always-On TOP Power Domain RING generation ##
################################################
## MANUAL TASK
##Create a VDD VSS Ring around the core
##Create a ring around the core for VDD and VSS in metal 5 (hor.) and metal 6 (vert.)
##with a width of 12? each and a spacing of 2.0? between the wires on all sides and an offset to the core of 1.0 ?.
#addRing \
#-around default_power_domain \
#-nets {VDD VSS} \
#-layer {bottom M5 top M5 right M6 left M6} \
#-width 10 \
#-spacing 4 \
#-offset 1

################################
## Global VSS GRID generation ##
################################
addStripe \
 -set_to_set_distance 12 \
 -spacing 12 \
 -xleft_offset 5.05 \
 -direction vertical \
 -layer M6 \
 -width 2.3 \
 -nets VSS

set aescore_x1 [expr [dbGet top.FPlan.CoreBox_llx] + 19.35]
set aescore_y1 [expr [dbGet top.FPlan.CoreBox_ury] - 220]
set aescore_x2 [expr [dbGet top.FPlan.CoreBox_urx] - 20.95]
set aescore_y2 [expr [dbGet top.FPlan.CoreBox_ury] - 22]

addStripe \
 -set_to_set_distance 10.26 \
 -spacing 10.26 \
 -ybottom_offset 3.980 \
 -direction horizontal \
 -layer M5 \
 -width 2.3 \
 -nets VSS \
 -area_blockage "$aescore_x1 $aescore_y1 $aescore_x2 $aescore_y2"

#####################################################
## VDD1 stripes generation for Header Power Switch ##
#####################################################
#addStripe -extend_to design_boundary \
# -set_to_set_distance 96 \
# -spacing 96 \
# -xleft_offset 69.7 \
# -direction vertical \
# -layer M4 \
# -width 5 \
# -area_blockage "0 [expr [dbGet top.FPlan.CoreBox_lly] + 70 + 5]  [dbGet top.fplan.box_urx] [dbGet top.fplan.box_ury] " \
# -nets VDD1

####################################################
## Always-On VDD TOP Power Domain GRID generation ##
####################################################
setAddStripeMode -extend_to_closest_target ring
addStripe \
 -nets VDD \
 -direction vertical \
 -layer M6 \
 -xleft_offset 11.05 \
 -width 2.3 \
 -spacing 12 \
 -set_to_set_distance 12

############################################
## KERNEL Switched Power Domain creation ##
############################################
set aescore_x1 [expr [dbGet top.FPlan.CoreBox_llx] + 23]
set aescore_y1 [expr [dbGet top.FPlan.CoreBox_ury] - 215]
set aescore_x2 [expr [dbGet top.FPlan.CoreBox_urx] - 27]
set aescore_y2 [expr [dbGet top.FPlan.CoreBox_ury] - 24]
modifyPowerDomainAttr AES_PSO -minGaps 5 5 5 5 -box $aescore_x1 $aescore_y1 $aescore_x2 $aescore_y2

addStripe \
 -nets VDD \
 -direction horizontal \
 -layer M5 \
 -ybottom_offset 9.11 \
 -width 2.3 \
 -spacing 10.26 \
 -set_to_set_distance 10.26

deselectAll
selectObject Group AES_PSO
addStripe \
 -over_power_domain 1 \
 -set_to_set_distance 12 \
 -spacing 12 \
 -xleft_offset 9.05 \
 -layer M4 \
 -width 2.3 \
 -use_wire_group_bits 1 \
 -use_wire_group 1 \
 -nets VDDSW
deselectAll


##################################
## Insert header Power Switches ##
##################################
addPowerSwitch -column  \
    -powerDomain AES_PSO \
    -horizontalPitch 48 \
    -leftOffset 0.8 \
    -skipRows 0 \
    -topDown 1 \
    -backToBackChain LToR \
    -checkerBoard 1 \
    -switchModuleInstance AESCORE
 #Not needed and can interfer with CPF
 #-enableNetIn nsleep_in
 #-enableNetOut nsleep_out

#############################################
## M1 power rails prerouting for Std Cells ##
#############################################
#Allow connectin M1 rail between different PD
setSrouteMode -corePinJoinLimit 6
sroute -connect corePin -nets VSS -allowJogging 0 -corePinMaxViaWidth 60
sroute -connect corePin -nets VDDSW -powerDomains AES_PSO -allowJogging 0 -corePinMaxViaWidth 60
sroute -connect corePin -nets VDD -powerDomains TOP -allowJogging 0 -corePinMaxViaWidth 60
clearDrc

###################################################
## VDD via connections from stripes to switches ##
###################################################
setSrouteMode -viaConnectToShape { stripe }
sroute \
-connect { secondaryPowerPin } \
-layerChangeRange { M1 M6 } \
-blockPinTarget { nearestTarget } \
-secondaryPinRailVerticalStripeGrid { M6 0 0 } \
-checkAlignedSecondaryPin 1 \
-deleteExistingRoutes \
-allowJogging 1 \
-powerDomains { AES_PSO } \
-crossoverViaLayerRange { M1 M6 } \
-nets { VDD } \
-allowLayerChange 1 \
-secondaryPinNet { VDD } \
-targetViaLayerRange { M1 M6 }

###############
## Reporting ##
###############
timeDesign -prePlace -outDir ../reports/floorplan -prefix timing
report_timing -format {instance pin cell net  load slew delay arrival}

timeDesign -prePlace -expandedViews -numPaths 10 -outDir ../reports/floorplan -prefix timing
timeDesign -prePlace -hold -expandedViews -numPaths 10 -outDir ../reports/floorplan -prefix timing

reportGateCount -stdCellOnly -outfile ../reports/floorplan/stdGateCount.rpt
analyzeFloorplan -outfile ../reports/floorplan/AnalyzeFloorplan.rpt

##########################
## Check DRC		##
##########################
verifyGeometry

##########################
## Save Design and exit ##
##########################
clearDrc
foreach mode [ all_constraint_modes ] {
    eval "update_constraint_mode -name $mode -sdc \"[ get_constraint_mode  $mode -sdc_files ]\""
}
saveDesign ../data/floorplan.inn

#exit
