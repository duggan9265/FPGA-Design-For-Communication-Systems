-- vhdl-linter-disable type-resolved
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fcs_check_serial IS
GENERIC(
    DEPTH : INTEGER := 32
);
PORT (
    CLK : IN STD_LOGIC; --Sys Clock 
    RST : IN STD_LOGIC; --Async Reset 
    START_OF_FRAME : IN STD_LOGIC; --Arrival of first bit 
    END_OF_FRAME : IN STD_LOGIC; --Arrival of 1st bit in FCS 
    DATA_IN : IN STD_LOGIC; --serial input data 
    FCS_ERROR : OUT STD_LOGIC --indicates an error 
);
END fcs_check_serial;

ARCHITECTURE rtl OF fcs_check_serial IS 
---------------------------------signals----------------------------------------------------------------
signal shift_mem : STD_LOGIC_VECTOR(DEPTH-1 DOWNTO 0) := (OTHERS => '0'); -- registers must be 0 before calculation starts.
signal check_error : STD_LOGIC;
---------------------------------end signals----------------------------------------------------------------
BEGIN
    FCS_error_process : PROCESS(CLK, RST) -- Have async reset
        BEGIN 
            IF (RST = '0') THEN 
                shift_mem <= (OTHERS => '0');  --reset is active low
                check_error <= '0';
                FCS_ERROR <= '0';

            ELSIF (rising_edge(CLK)) THEN 
                IF START_OF_FRAME = '1' THEN
                    shift_mem(DEPTH-1 DOWNTO 1) <= shift_mem(DEPTH-2 DOWNTO 0); --shifts left i.e 0-1, 1-2
                    shift_mem(31) <= shift_mem(30);
                    shift_mem(26) <= shift_mem(25) XOR shift_mem(31);
                    shift_mem(23) <= shift_mem(22) XOR shift_mem(31);
                    shift_mem(22) <= shift_mem(21) XOR shift_mem(31);
                    shift_mem(16) <= shift_mem(15) XOR shift_mem(31);
                    shift_mem(12) <= shift_mem(11) XOR shift_mem(31);
                    shift_mem(11) <= shift_mem(10) XOR shift_mem(31);
                    shift_mem(10) <= shift_mem(9)  XOR shift_mem(31);
                    shift_mem(8)  <= shift_mem(7)  XOR shift_mem(31);
                    shift_mem(7)  <= shift_mem(6)  XOR shift_mem(31);
                    shift_mem(5)  <= shift_mem(4)  XOR shift_mem(31);
                    shift_mem(4)  <= shift_mem(3)  XOR shift_mem(31);
                    shift_mem(2)  <= shift_mem(1)  XOR shift_mem(31);
                    shift_mem(1)  <= shift_mem(0)  XOR shift_mem(31);
                    shift_mem(0) <= shift_mem(31) XOR DATA_IN;-- XOR with input for polynomial division
                END IF;

                IF END_OF_FRAME = '1' THEN 
                    check_error <= '1';
                END IF; 

                IF check_error = '1' THEN
                    IF shift_mem = (shift_mem'RANGE => '0') THEN
                        FCS_ERROR <= '0'; -- No error detected
                    ELSE 
                        FCS_ERROR <= '1'; -- Error detected
                    END IF;
                END IF;
            END IF;
        END PROCESS;                    
END rtl;