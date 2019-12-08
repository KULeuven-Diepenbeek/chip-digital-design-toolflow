# Set OCV parameters

#-7.5% on capture path
set_timing_derate -early 0.925 -late 1.0 -delay_corner AV_on_mode_wc_rc125_setup_dc
set_timing_derate -early 0.925 -late 1.0 -delay_corner AV_sleep_mode_wc_rc125_setup_dc
#-27% on launch path
set_timing_derate -early 0.73 -late 1.0 -delay_corner AV_on_mode_wc_rc125_hold_dc
set_timing_derate -early 0.73 -late 1.0 -delay_corner AV_sleep_mode_wc_rc125_hold_dc
#+12% on capture path
set_timing_derate -early 1.0 -late 1.12 -delay_corner AV_on_mode_bc_rc0_hold_dc
set_timing_derate -early 1.0 -late 1.12 -delay_corner AV_sleep_mode_bc_rc0_hold_dc
