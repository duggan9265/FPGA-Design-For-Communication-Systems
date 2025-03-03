-- Author: Daniel Duggan
-- vhdl-linter-disable type-resolved
-- LIBRARY ieee;
-- USE ieee.std_logic_1164.ALL;
-- USE ieee.numeric_std.ALL;

-- ENTITY fcs_check_serial IS
--     GENERIC (
--         DEPTH : INTEGER := 32
--     );
--     PORT (
--         CLK : IN STD_LOGIC; --Sys Clock 
--         RST : IN STD_LOGIC; --Async Reset 
--         START_OF_FRAME : IN STD_LOGIC := '0'; --Arrival of first bit 
--         END_OF_FRAME : IN STD_LOGIC := '0'; --Arrival of 1st bit in FCS 
--         DATA_IN : IN STD_LOGIC; --serial input data 
--         FCS_ERROR : OUT STD_LOGIC --indicates an error 
--     );
-- END fcs_check_serial;

-- ARCHITECTURE rtl OF fcs_check_serial IS
--     ---------------------------------signals----------------------------------------------------------------
--     SIGNAL shift_mem : STD_LOGIC_VECTOR(DEPTH - 1 DOWNTO 0); -- registers must be 0 before calculation starts.
--     SIGNAL data_to_crc : STD_LOGIC := '0';
--     SIGNAL bit_count : UNSIGNED(9 DOWNTO 0) := (OTHERS => '0');
--     SIGNAL fcs_complete : STD_LOGIC := '0';

--     ---------------------------------end signals----------------------------------------------------------------
-- BEGIN

--     data_processing : PROCESS (DATA_IN, START_OF_FRAME, END_OF_FRAME)
--         VARIABLE process_data : STD_LOGIC;
--     BEGIN
--         IF START_OF_FRAME = '1' THEN
--             process_data := '1';
--         END IF;

--         IF process_data = '1' THEN
--             data_to_crc <= DATA_IN;
--             IF (START_OF_FRAME = '1'  AND bit_count < 31) OR  (END_OF_FRAME = '1' AND bit_count > 479) THEN
--                 data_to_crc <= NOT DATA_IN;
--             END IF;
--         END IF;
--     END PROCESS;

--     FCS_error_process : PROCESS (CLK, RST) -- Have async reset
--     BEGIN
--         IF (RST = '0') THEN -- Have an active low reset
--             shift_mem <= (OTHERS => '0');
--             bit_count <= (OTHERS => '0');
--             FCS_ERROR <= '0';

--         ELSIF (rising_edge(CLK)) THEN

--             IF START_OF_FRAME = '1' THEN
--                 bit_count <= (OTHERS => '0');
--             ELSE 
--                 bit_count <= bit_count + 1;
--             END IF;

--             --shift_mem(DEPTH - 1 DOWNTO 1) <= shift_mem(DEPTH - 2 DOWNTO 0); -- left shift, R(n+1) <= R(n), R(n) <= R(n-1)
--             shift_mem(0) <= shift_mem(31) XOR data_to_crc;-- XOR with input for polynomial division
--             shift_mem(1) <= shift_mem(0) XOR shift_mem(31);
--             shift_mem(2) <= shift_mem(1) XOR shift_mem(31);
--             shift_mem(3) <= shift_mem(2);
--             shift_mem(4) <= shift_mem(3) XOR shift_mem(31);
--             shift_mem(5) <= shift_mem(4) XOR shift_mem(31);
--             shift_mem(6) <= shift_mem(5);
--             shift_mem(7) <= shift_mem(6) XOR shift_mem(31);
--             shift_mem(8) <= shift_mem(7) XOR shift_mem(31);
--             shift_mem(9) <= shift_mem(8);
--             shift_mem(10) <= shift_mem(9) XOR shift_mem(31);
--             shift_mem(11) <= shift_mem(10) XOR shift_mem(31);
--             shift_mem(12) <= shift_mem(11) XOR shift_mem(31);
--             shift_mem(13) <= shift_mem(12);
--             shift_mem(14) <= shift_mem(13);
--             shift_mem(15) <= shift_mem(14);
--             shift_mem(16) <= shift_mem(15) XOR shift_mem(31);
--             shift_mem(17) <= shift_mem(16);
--             shift_mem(18) <= shift_mem(17);
--             shift_mem(19) <= shift_mem(18);
--             shift_mem(20) <= shift_mem(19);
--             shift_mem(21) <= shift_mem(20);
--             shift_mem(22) <= shift_mem(21) XOR shift_mem(31);
--             shift_mem(23) <= shift_mem(22);
--             shift_mem(24) <= shift_mem(23);
--             shift_mem(25) <= shift_mem(24);
--             shift_mem(26) <= shift_mem(25) XOR shift_mem(31);
--             shift_mem(27) <= shift_mem(26);
--             shift_mem(28) <= shift_mem(27);
--             shift_mem(29) <= shift_mem(28);
--             shift_mem(30) <= shift_mem(29);
--             shift_mem(31) <= shift_mem(30);
--         END IF;

--         IF bit_count > 511 THEN
--             fcs_complete <= '1';
--         END IF;

--         IF fcs_complete = '1' THEN
--             IF shift_mem = (shift_mem'RANGE => '0') THEN
--                 FCS_ERROR <= '0';
--             ELSE
--                 FCS_ERROR <= '1';
--             END IF;
--         END IF;
--     END PROCESS;
-- END rtl;