LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fcs_check_serial IS
PORT (
    CLK : IN STD_LOGIC; --Sys Clock -- vhdl-linter-disable-line type-resolved
    RST : IN STD_LOGIC; --Async Reset -- vhdl-linter-disable-line type-resolved
    START_OF_FRAME : IN STD_LOGIC; --Arrival of first bit -- vhdl-linter-disable-line type-resolved
    END_OF_FRAME : IN STD_LOGIC; --Arrival of 1st bit in FCS -- vhdl-linter-disable-line type-resolved
    DATA_IN : STD_LOGIC; --serial input data -- vhdl-linter-disable-line type-resolved
    FCS_ERROR : STD_LOGIC --indicates an error -- vhdl-linter-disable-line type-resolved
);
END fcs_check_serial;

ARCHITECTURE rtl OF fcs_check_serial IS 
--signals
BEGIN

END rtl;