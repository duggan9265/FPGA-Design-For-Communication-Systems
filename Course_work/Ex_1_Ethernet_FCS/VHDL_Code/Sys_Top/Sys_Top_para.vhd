-- Author Daniel Duggan
-- vhdl-linter-disable type-resolved
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

USE IEEE.NUMERIC_STD.ALL;

LIBRARY UNISIM;
USE UNISIM.VCOMPONENTS.ALL; -- Required for IBUFDS -- vhdl-linter-disable-line not-declared

ENTITY Sys_Top_para IS
    PORT(
        SYS_CLOCK_P : IN STD_LOGIC;  -- LVDS clock positive
        SYS_CLOCK_N : IN STD_LOGIC;  -- LVDS clock negative
        RST : IN STD_LOGIC;
        START_OF_FRAME_top : IN STD_LOGIC;
        END_OF_FRAME_top : IN STD_LOGIC;
        DATA_IN_top : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        FCS_ERROR_top : OUT STD_LOGIC -- vhdl-linter-disable-line type-resolved
    );
END Sys_Top_para;

ARCHITECTURE rtl OF sys_top_para IS
    -- Single-ended clock signal after differential conversion
    SIGNAL sysclk_single : STD_LOGIC; -- vhdl-linter-disable-line type-resolved
    
BEGIN
    -- Convert the differential clock to single-ended using IBUFDS
    clk_buffer: IBUFDS -- don't use work as this is not a user defined entity -- vhdl-linter-disable-line not-declared
    PORT MAP (
        I  => SYS_CLOCK_P,  -- Positive clock input
        IB => SYS_CLOCK_N,  -- Negative clock input
        O  => sysclk_single -- Output single-ended clock
    );

    -- Instance of fcs_check_serial using the single-ended clock
    fcs_parallel_FSM_inst: entity work.fcs_check_parallel_FSM
    PORT MAP (
        CLK => sysclk_single,  -- Send the converted clock
        RST => RST,
        START_OF_FRAME => START_OF_FRAME_top,
        END_OF_FRAME => END_OF_FRAME_top,
        DATA_IN => DATA_IN_top,
        FCS_ERROR => FCS_ERROR_top
    );

END rtl;