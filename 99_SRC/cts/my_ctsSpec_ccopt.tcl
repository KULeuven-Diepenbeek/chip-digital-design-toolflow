#Create Non-Default_Rule for clock routing
add_ndr -name default_2x_space -spacing {M1 0.38 M2:M5 0.42 M6 0.84}

create_route_type -name leaf_rule  -non_default_rule default_2x_space -top_preferred_layer metal4 -bottom_preferred_layer metal2
create_route_type -name trunk_rule -non_default_rule default_2x_space -top_preferred_layer metal4 -bottom_preferred_layer metal2 -shield_net VSS -shield_side both_side
create_route_type -name top_rule   -non_default_rule default_2x_space -top_preferred_layer metal4 -bottom_preferred_layer metal2 -shield_net VSS -shield_side both_side

set_ccopt_property route_type -net_type leaf  leaf_rule
set_ccopt_property route_type -net_type trunk trunk_rule
set_ccopt_property route_type -net_type top   top_rule


set_ccopt_property target_max_trans 0.100
set_ccopt_property target_skew 0.150
#set_ccopt_property max_fanout 20
set_ccopt_property update_io_latency 0

#Specify the buffers/inverters to use
set_ccopt_property buffer_cells {CLKBUF_X1 CLKBUF_X2 CLKBUF_X3}
set_ccopt_property inverter_cells {AON_INV_X1 AON_INV_X2 AON_INV_X4}
