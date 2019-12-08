#suppressMessage ENCLF 58 119 151 200 223 TECHLIB 436 ENCFP 3961 EMS 42 ENCEXT 2766 2773 2775 2777 2766
#suppressMessage ENCLF 58 200 3961
suppressMessage TECHLIB 436 302
#suppressMessage ENCTS 3
suppressMessage IMPEXT 2773
#OpenAccess (OA) library related message
suppressMessage IMPOAX 124 332

setDesignMode -process 45
setAnalysisMode -analysisType onChipVariation -cppr both -checkType setup
set_global report_timing_format {instance pin cell net fanout load slew delay arrival edge incr_delay user_derate }

#Flow variable
set manual_task 0
set chip_top AES_CHIP
