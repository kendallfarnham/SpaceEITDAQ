## 2023_DAQ
#------------------------------------------------------------
## NOTES
#------------------------------------------------------------
# pga_x[0:2] = CSn, SI, SCK                                 # PGA DIO inputs
# mux_x[0:7] = S0, S1, S2, S3, NEN1, NEN2, NEN3, NEN4       # MUX DIO inputs

#------------------------------------------------------------
## CONSTRAINTS
#------------------------------------------------------------
## Configuration options, bank 0 IO voltages
## Documentation p. 36 of ug470_7Series_Config.pdf
#set_property CONFIG_VOLTAGE 3.3 [current_design]; # (was 1.8 for Arty)
#set_property CFGBVS VCCO [current_design]; # (was GND for Arty)
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS GND [current_design]
#------------------------------------------------------------
## Clock signal
set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports sysclk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports sysclk]

# Generated clocks
create_generated_clock -name fwd_dclk -source [get_pins dac_clk_forward/C] -multiply_by 1 [get_ports dclk_dds]
create_generated_clock -name fwd_pgaclk_i -source [get_pins pga_isense_sclk_forward/C] -multiply_by 1 [get_ports pga_isense_clk]
create_generated_clock -name fwd_pgaclk_v1 -source [get_pins pga_vpu1_sclk_forward/C] -multiply_by 1 [get_ports pga_vpu1_clk]
create_generated_clock -name fwd_pgaclk_v2 -source [get_pins pga_vpu2_sclk_forward/C] -multiply_by 1 [get_ports pga_vpu2_clk]
create_generated_clock -name fwd_aclk_i -source [get_pins aclk_i_forward/C] -multiply_by 1 [get_ports aclk_isense]
create_generated_clock -name fwd_aclk_v1 -source [get_pins aclk_v1_forward/C] -multiply_by 1 [get_ports aclk_vpu1]
create_generated_clock -name fwd_aclk_v2 -source [get_pins aclk_v2_forward/C] -multiply_by 1 [get_ports aclk_vpu2]

#------------------------------------------------------------
# Clock domain crossings
#set_clock_groups -name async_dds_clk_grp -asynchronous 
#    -group [get_clocks clk_out_125M_clk_wiz_0] 
#    -group [get_clocks clk_out_15M_clk_wiz_0] 
#    -group [get_clocks sys_clk_pin]

#------------------------------------------------------------
# UART ports
set_property -dict {PACKAGE_PIN R10 IOSTANDARD LVCMOS33} [get_ports uart_txd_out]
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports uart_txd_in]

# LEDs
#set_property -dict {PACKAGE_PIN A8 IOSTANDARD LVCMOS18} [get_ports LEDS[0]];
#set_property -dict {PACKAGE_PIN L15 IOSTANDARD LVCMOS33} [get_ports LEDS[1]];
#set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports LEDS[2]];

# Reset
#set_property -dict {PACKAGE_PIN D9 IOSTANDARD LVCMOS18} [get_ports master_reset_in];

################################################################
## DIGITAL IO B2B CONNECTIONS - J1 and J2
################################################################

###################### GROUP 1 DIGITAL IO ######################
## Digital IO - TE0703 B2B J1 Column A
set_property -dict {PACKAGE_PIN B12 IOSTANDARD LVCMOS33} [get_ports {mux_vsink_odd[5]}]
set_property -dict {PACKAGE_PIN C12 IOSTANDARD LVCMOS33} [get_ports {mux_vsink_odd[2]}]
set_property -dict {PACKAGE_PIN D15 IOSTANDARD LVCMOS33} [get_ports {mux_vsink_odd[4]}]
set_property -dict {PACKAGE_PIN C15 IOSTANDARD LVCMOS33} [get_ports {mux_vsink_odd[3]}]
set_property -dict {PACKAGE_PIN F15 IOSTANDARD LVCMOS33} [get_ports {mux_vsink_odd[1]}]
set_property -dict {PACKAGE_PIN F16 IOSTANDARD LVCMOS33} [get_ports {mux_vsink_odd[0]}]
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports {mux_vsrc_odd[0]}]
set_property -dict {PACKAGE_PIN G16 IOSTANDARD LVCMOS33} [get_ports {mux_vsrc_odd[1]}]
set_property -dict {PACKAGE_PIN A15 IOSTANDARD LVCMOS33} [get_ports {mux_vsrc_odd[3]}]
set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports {mux_vsrc_odd[2]}]
set_property -dict {PACKAGE_PIN F18 IOSTANDARD LVCMOS33} [get_ports {mux_vsrc_odd[4]}]
set_property -dict {PACKAGE_PIN G18 IOSTANDARD LVCMOS33} [get_ports {mux_vsrc_odd[5]}]
set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports {mux_vpu1[0]}]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports {mux_vpu1[1]}]
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports {mux_vpu1[3]}]
set_property -dict {PACKAGE_PIN F13 IOSTANDARD LVCMOS33} [get_ports {mux_vpu1[2]}]

## Digital IO - TE0703 B2B J1 Column B
set_property -dict {PACKAGE_PIN C14 IOSTANDARD LVCMOS33} [get_ports {dds_out[13]}]
set_property -dict {PACKAGE_PIN D14 IOSTANDARD LVCMOS33} [get_ports {dds_out[11]}]
set_property -dict {PACKAGE_PIN D17 IOSTANDARD LVCMOS33} [get_ports {dds_out[9]}]
set_property -dict {PACKAGE_PIN E17 IOSTANDARD LVCMOS33} [get_ports {dds_out[7]}]
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports {dds_out[5]}]
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {dds_out[3]}]
set_property -dict {PACKAGE_PIN E15 IOSTANDARD LVCMOS33} [get_ports {dds_out[1]}]
#set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVCMOS33} [get_ports {pga_isense_cs_n}]; # J1-B10
set_property -dict {PACKAGE_PIN J13 IOSTANDARD LVCMOS33} [get_ports {pga_vpu1_cs_n}]
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS33} [get_ports {pga_vpu1_clk}]
set_property -dict {PACKAGE_PIN D13 IOSTANDARD LVCMOS33} [get_ports pga_isense_cs_n]; # J1-B13
#set_property -dict {PACKAGE_PIN D12 IOSTANDARD LVCMOS33} [get_ports dio[0]]; # J1-B14
#set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33} [get_ports dio[0]]; # J1-B15
#set_property -dict {PACKAGE_PIN B18 IOSTANDARD LVCMOS33} [get_ports dio[0]]; # J1-B16
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports {mux_vpu1[4]}]
set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS33} [get_ports {mux_vpu1[5]}]

## Digital IO - TE0703 B2B J1 Column C
set_property -dict {PACKAGE_PIN B13 IOSTANDARD LVCMOS33} [get_ports dclk_dds]
set_property -dict {PACKAGE_PIN B14 IOSTANDARD LVCMOS33} [get_ports {dds_out[12]}]
set_property -dict {PACKAGE_PIN C16 IOSTANDARD LVCMOS33} [get_ports {dds_out[10]}]
set_property -dict {PACKAGE_PIN C17 IOSTANDARD LVCMOS33} [get_ports {dds_out[8]}]
set_property -dict {PACKAGE_PIN B11 IOSTANDARD LVCMOS33} [get_ports {dds_out[6]}]
set_property -dict {PACKAGE_PIN A11 IOSTANDARD LVCMOS33} [get_ports {dds_out[4]}]
set_property -dict {PACKAGE_PIN A13 IOSTANDARD LVCMOS33} [get_ports {dds_out[2]}]
set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33} [get_ports {dds_out[0]}]
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports {pga_isense_si}]
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33} [get_ports {pga_isense_clk}]
set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports {pga_vpu1_si}]
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports {pga_vpu2_cs_n}]
set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33} [get_ports {pga_vpu2_si}]
set_property -dict {PACKAGE_PIN B17 IOSTANDARD LVCMOS33} [get_ports {pga_vpu2_clk}]
set_property -dict {PACKAGE_PIN H14 IOSTANDARD LVCMOS33} [get_ports done_tx]; # J1-C17		IO_L15P_T2_DQS_15


###################### GROUP 3 DIGITAL IO ######################
## Digital IO - TE0703 B2B J2 Column A
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports {mux_vsink_even[1]}]
set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports {mux_vsrc_even[3]}]
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS33} [get_ports {mux_vsrc_even[4]}]
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports {mux_vsrc_even[5]}]
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {mux_vpu2[5]}]
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports {mux_vpu2[2]}]

## Digital IO - TE0703 B2B J2 Column B
set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS33} [get_ports {mux_vsink_even[0]}]
set_property -dict {PACKAGE_PIN M16 IOSTANDARD LVCMOS33} [get_ports {mux_vsink_even[5]}]
set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS33} [get_ports {mux_vsrc_even[2]}]
set_property -dict {PACKAGE_PIN V11 IOSTANDARD LVCMOS33} [get_ports {mux_vsrc_even[1]}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {mux_vpu2[1]}]
set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports {mux_vpu2[3]}]

## Digital IO - TE0703 B2B J2 Column C
set_property -dict {PACKAGE_PIN T9 IOSTANDARD LVCMOS33} [get_ports {mux_vsink_even[2]}]
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {mux_vsink_even[4]}]
set_property -dict {PACKAGE_PIN U11 IOSTANDARD LVCMOS33} [get_ports {mux_vsink_even[3]}]
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports {mux_vsrc_even[0]}]
set_property -dict {PACKAGE_PIN R15 IOSTANDARD LVCMOS33} [get_ports {mux_vpu2[4]}]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {mux_vpu2[0]}]


####################### GROUP 4 DIGITAL IO ######################
################ Bank 35, HR only supports LVDS_25 ##############
## Digital IO - TE0703 B2B J2 Column A
set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVDS_25} [get_ports lvds_isense_db_n]
set_property -dict {PACKAGE_PIN C4 IOSTANDARD LVDS_25} [get_ports lvds_isense_db_p]
set_property -dict {PACKAGE_PIN A6 IOSTANDARD LVCMOS25} [get_ports vpu1_pwr_dwn]
set_property -dict {PACKAGE_PIN A5 IOSTANDARD LVCMOS25} [get_ports vpu1_testpat]
set_property -dict {PACKAGE_PIN B3 IOSTANDARD LVCMOS25} [get_ports vpu1_twolanes]
set_property -dict {PACKAGE_PIN B2 IOSTANDARD LVCMOS25} [get_ports aclk_isense]
set_property -dict {PACKAGE_PIN D4 IOSTANDARD LVCMOS25} [get_ports aclk_vpu1]
set_property -dict {PACKAGE_PIN D5 IOSTANDARD LVCMOS25} [get_ports vpu2_pwr_dwn]
set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS25} [get_ports vpu2_testpat]
set_property -dict {PACKAGE_PIN E5 IOSTANDARD LVDS_25} [get_ports lvds_vpu2_clk_n]
set_property -dict {PACKAGE_PIN E6 IOSTANDARD LVDS_25} [get_ports lvds_vpu2_clk_p]

## Digital IO - TE0703 B2B J2 Column B
set_property -dict {PACKAGE_PIN B6 IOSTANDARD LVCMOS25} [get_ports isense_twolanes]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVDS_25} [get_ports lvds_vpu1_da_n]
set_property -dict {PACKAGE_PIN F1 IOSTANDARD LVDS_25} [get_ports lvds_vpu1_da_p]
set_property -dict {PACKAGE_PIN D3 IOSTANDARD LVDS_25} [get_ports lvds_vpu1_clk_n]
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVDS_25} [get_ports lvds_vpu1_clk_p]
set_property -dict {PACKAGE_PIN F3 IOSTANDARD LVDS_25} [get_ports lvds_vpu2_da_n]
set_property -dict {PACKAGE_PIN F4 IOSTANDARD LVDS_25} [get_ports lvds_vpu2_da_p]
#set_property -dict {PACKAGE_PIN K1 IOSTANDARD LVDS_25} [get_ports lvds_vpu2_dco_n]; # J2-B17		IO_L23N_T3_35
#set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVDS_25} [get_ports lvds_vpu2_dco_p]; # J2-B18		IO_L23P_T3_35

## Digital IO - TE0703 B2B J2 Column C
set_property -dict {PACKAGE_PIN C6 IOSTANDARD LVCMOS25} [get_ports isense_pwr_dwn]
set_property -dict {PACKAGE_PIN C5 IOSTANDARD LVCMOS25} [get_ports isense_testpat]
set_property -dict {PACKAGE_PIN D7 IOSTANDARD LVDS_25} [get_ports lvds_isense_da_n]
set_property -dict {PACKAGE_PIN E7 IOSTANDARD LVDS_25} [get_ports lvds_isense_da_p]
#set_property -dict {PACKAGE_PIN F6 IOSTANDARD LVDS_25} [get_ports lvds_isense_dco_n]; # J2-C6		IO_L19N_T3_VREF_35
#set_property -dict {PACKAGE_PIN G6 IOSTANDARD LVDS_25} [get_ports lvds_isense_dco_p]; # J2-C7		IO_L19P_T3_35
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVDS_25} [get_ports lvds_isense_clk_n]
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVDS_25} [get_ports lvds_isense_clk_p]


set_property -dict {PACKAGE_PIN G3 IOSTANDARD LVDS_25} [get_ports lvds_vpu1_db_n]
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVDS_25} [get_ports lvds_vpu1_db_p]
#set_property -dict {PACKAGE_PIN D2 IOSTANDARD LVDS_25} [get_ports lvds_vpu1_dco_n]; # J2-C12		IO_L14N_T2_SRCC_35
#set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVDS_25} [get_ports lvds_vpu1_dco_p]; # J2-C13		IO_L14P_T2_SRCC_35
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVDS_25} [get_ports lvds_vpu2_db_n]
set_property -dict {PACKAGE_PIN J4 IOSTANDARD LVDS_25} [get_ports lvds_vpu2_db_p]
set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS25} [get_ports vpu2_twolanes]
set_property -dict {PACKAGE_PIN H6 IOSTANDARD LVCMOS25} [get_ports aclk_vpu2]


