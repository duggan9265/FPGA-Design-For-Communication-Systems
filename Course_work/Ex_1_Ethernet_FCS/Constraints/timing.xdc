## External clock input

# Create a clock constraint using the P-side of the differential pair
create_clock -name sys_clk -period 4 [get_ports SYS_CLOCK_P]

# Define the differential clock input pins, -dict combines properties into single command
set_property -dict {PACKAGE_PIN AL8 IOSTANDARD LVDS} [get_ports SYS_CLOCK_P] 
set_property -dict {PACKAGE_PIN AL9 IOSTANDARD LVDS} [get_ports SYS_CLOCK_N]

##End external clock input




