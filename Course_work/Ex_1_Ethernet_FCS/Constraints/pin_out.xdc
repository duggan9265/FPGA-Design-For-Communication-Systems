set_property -dict {PACKAGE_PIN H13 IOSTANDARD LVCMOS33} [get_ports {DATA_IN_top}] 
set_property -dict {PACKAGE_PIN F20 IOSTANDARD LVCMOS33} [get_ports {START_OF_FRAME_top}]
set_property -dict {PACKAGE_PIN E20 IOSTANDARD LVCMOS33} [get_ports {END_OF_FRAME_top}]
set_property -dict {PACKAGE_PIN G20 IOSTANDARD LVCMOS33} [get_ports {RST}]
set_property -dict {PACKAGE_PIN D22 IOSTANDARD LVCMOS33} [get_ports {FCS_ERROR_top}]