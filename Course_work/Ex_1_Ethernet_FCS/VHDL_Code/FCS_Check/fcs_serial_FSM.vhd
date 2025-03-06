-- Auther Daniel Duggan
-- vhdl-linter-disable type-resolved
LIBRARY IEEE;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_1164.ALL;

ENTITY fcs_check_serial IS --fsm_fcs
    GENERIC (
        Depth : INTEGER := 32
    );

    PORT (
        CLK : IN STD_ULOGIC; --Sys Clock 
        RST : IN STD_ULOGIC; --Async Reset 
        START_OF_FRAME : IN STD_ULOGIC := '0'; --Arrival of first bit 
        END_OF_FRAME : IN STD_ULOGIC := '0'; --Arrival of 1st bit in FCS 
        DATA_IN : IN STD_ULOGIC; --serial input data 
        FCS_ERROR : OUT STD_ULOGIC --indicates an error 
    );
END ENTITY;

ARCHITECTURE fsm OF fcs_check_serial IS
    TYPE fsm_fcs_type IS
    (idle, data_recieve, fcs_recieve, check_fcs, error_check);
    SIGNAL state, next_state : fsm_fcs_type; --state, next_state can take on all values inside fsm_fcs_type
    SIGNAL bit_count : unsigned(9 DOWNTO 0);
    SIGNAL shift_mem : STD_LOGIC_VECTOR(DEPTH - 1 DOWNTO 0);
    SIGNAL check_data : STD_LOGIC; -- For debug purposes only
BEGIN
    fsm_process : PROCESS (state, START_OF_FRAME, END_OF_FRAME, bit_count)
    BEGIN
        CASE state IS
            WHEN idle =>
                IF START_OF_FRAME = '1' THEN
                    next_state <= data_recieve;
                ELSE
                    next_state <= idle;
                END IF;

            WHEN data_recieve =>
                IF END_OF_FRAME = '1' THEN
                    next_state <= fcs_recieve;
                ELSE
                    next_state <= data_recieve;
                END IF;

            WHEN fcs_recieve =>
                IF bit_count = 511 THEN
                    next_state <= check_fcs;
                ELSE
                    next_state <= fcs_recieve;
                END IF;

            WHEN CHECK_FCS =>
                next_state <= error_check;

            WHEN error_check =>
                next_state <= idle; -- Reset for the next frame

            WHEN OTHERS =>
                next_state <= idle;
        END CASE;
    END PROCESS;

    PROCESS (CLK, RST)
    BEGIN
        IF RST = '0' THEN --active low reset
            state <= idle;
            shift_mem <= (OTHERS => '0');
            bit_count <= (OTHERS => '0');
            bit_count <= (OTHERS => '0');
        ELSIF rising_edge(CLK) THEN
            state <= next_state;

            CASE state IS
                WHEN idle =>
                    shift_mem <= (OTHERS => '0');
                    bit_count <= (OTHERS => '0');
                    FCS_ERROR <= '0';

                WHEN data_recieve =>
                    check_data <= NOT DATA_IN;
                    IF bit_count < 32 THEN
                        shift_mem(0) <= shift_mem(31) XOR (NOT(DATA_IN)); -- Complement first 32 bits
                        shift_mem(1) <= shift_mem(0) XOR shift_mem(31);
                        shift_mem(2) <= shift_mem(1) XOR shift_mem(31);
                        shift_mem(3) <= shift_mem(2);
                        shift_mem(4) <= shift_mem(3) XOR shift_mem(31);
                        shift_mem(5) <= shift_mem(4) XOR shift_mem(31);
                        shift_mem(6) <= shift_mem(5);
                        shift_mem(7) <= shift_mem(6) XOR shift_mem(31);
                        shift_mem(8) <= shift_mem(7) XOR shift_mem(31);
                        shift_mem(9) <= shift_mem(8);
                        shift_mem(10) <= shift_mem(9) XOR shift_mem(31);
                        shift_mem(11) <= shift_mem(10) XOR shift_mem(31);
                        shift_mem(12) <= shift_mem(11) XOR shift_mem(31);
                        shift_mem(13) <= shift_mem(12);
                        shift_mem(14) <= shift_mem(13);
                        shift_mem(15) <= shift_mem(14);
                        shift_mem(16) <= shift_mem(15) XOR shift_mem(31);
                        shift_mem(17) <= shift_mem(16);
                        shift_mem(18) <= shift_mem(17);
                        shift_mem(19) <= shift_mem(18);
                        shift_mem(20) <= shift_mem(19);
                        shift_mem(21) <= shift_mem(20);
                        shift_mem(22) <= shift_mem(21) XOR shift_mem(31);
                        shift_mem(23) <= shift_mem(22) XOR shift_mem(31);
                        shift_mem(24) <= shift_mem(23);
                        shift_mem(25) <= shift_mem(24);
                        shift_mem(26) <= shift_mem(25) XOR shift_mem(31);
                        shift_mem(27) <= shift_mem(26);
                        shift_mem(28) <= shift_mem(27);
                        shift_mem(29) <= shift_mem(28);
                        shift_mem(30) <= shift_mem(29);
                        shift_mem(31) <= shift_mem(30);

                    ELSE
                        shift_mem(0) <= shift_mem(31) XOR DATA_IN; -- CRC shift logic
                        shift_mem(1) <= shift_mem(0) XOR shift_mem(31);
                        shift_mem(2) <= shift_mem(1) XOR shift_mem(31);
                        shift_mem(3) <= shift_mem(2);
                        shift_mem(4) <= shift_mem(3) XOR shift_mem(31);
                        shift_mem(5) <= shift_mem(4) XOR shift_mem(31);
                        shift_mem(6) <= shift_mem(5);
                        shift_mem(7) <= shift_mem(6) XOR shift_mem(31);
                        shift_mem(8) <= shift_mem(7) XOR shift_mem(31);
                        shift_mem(9) <= shift_mem(8);
                        shift_mem(10) <= shift_mem(9) XOR shift_mem(31);
                        shift_mem(11) <= shift_mem(10) XOR shift_mem(31);
                        shift_mem(12) <= shift_mem(11) XOR shift_mem(31);
                        shift_mem(13) <= shift_mem(12);
                        shift_mem(14) <= shift_mem(13);
                        shift_mem(15) <= shift_mem(14);
                        shift_mem(16) <= shift_mem(15) XOR shift_mem(31);
                        shift_mem(17) <= shift_mem(16);
                        shift_mem(18) <= shift_mem(17);
                        shift_mem(19) <= shift_mem(18);
                        shift_mem(20) <= shift_mem(19);
                        shift_mem(21) <= shift_mem(20);
                        shift_mem(22) <= shift_mem(21) XOR shift_mem(31);
                        shift_mem(23) <= shift_mem(22) XOR shift_mem(31);
                        shift_mem(24) <= shift_mem(23);
                        shift_mem(25) <= shift_mem(24);
                        shift_mem(26) <= shift_mem(25) XOR shift_mem(31);
                        shift_mem(27) <= shift_mem(26);
                        shift_mem(28) <= shift_mem(27);
                        shift_mem(29) <= shift_mem(28);
                        shift_mem(30) <= shift_mem(29);
                        shift_mem(31) <= shift_mem(30);
                    END IF;
                    bit_count <= bit_count + 1;

                WHEN fcs_recieve =>
                        
                        IF bit_count > 479 THEN
                        check_data <= NOT DATA_IN;
                        bit_count <= bit_count + 1;
                        shift_mem(0) <= shift_mem(31) XOR (NOT(DATA_IN)); -- Complement bits
                        shift_mem(1) <= shift_mem(0) XOR shift_mem(31);
                        shift_mem(2) <= shift_mem(1) XOR shift_mem(31);
                        shift_mem(3) <= shift_mem(2);
                        shift_mem(4) <= shift_mem(3) XOR shift_mem(31);
                        shift_mem(5) <= shift_mem(4) XOR shift_mem(31);
                        shift_mem(6) <= shift_mem(5);
                        shift_mem(7) <= shift_mem(6) XOR shift_mem(31);
                        shift_mem(8) <= shift_mem(7) XOR shift_mem(31);
                        shift_mem(9) <= shift_mem(8);
                        shift_mem(10) <= shift_mem(9) XOR shift_mem(31);
                        shift_mem(11) <= shift_mem(10) XOR shift_mem(31);
                        shift_mem(12) <= shift_mem(11) XOR shift_mem(31);
                        shift_mem(13) <= shift_mem(12);
                        shift_mem(14) <= shift_mem(13);
                        shift_mem(15) <= shift_mem(14);
                        shift_mem(16) <= shift_mem(15) XOR shift_mem(31);
                        shift_mem(17) <= shift_mem(16);
                        shift_mem(18) <= shift_mem(17);
                        shift_mem(19) <= shift_mem(18);
                        shift_mem(20) <= shift_mem(19);
                        shift_mem(21) <= shift_mem(20);
                        shift_mem(22) <= shift_mem(21) XOR shift_mem(31);
                        shift_mem(23) <= shift_mem(22) XOR shift_mem(31);
                        shift_mem(24) <= shift_mem(23);
                        shift_mem(25) <= shift_mem(24);
                        shift_mem(26) <= shift_mem(25) XOR shift_mem(31);
                        shift_mem(27) <= shift_mem(26);
                        shift_mem(28) <= shift_mem(27);
                        shift_mem(29) <= shift_mem(28);
                        shift_mem(30) <= shift_mem(29);
                        shift_mem(31) <= shift_mem(30);

                        else
                        check_data <= DATA_IN;
                        bit_count <= bit_count + 1;
                        shift_mem(0) <= shift_mem(31) XOR DATA_IN; 
                        shift_mem(1) <= shift_mem(0) XOR shift_mem(31);
                        shift_mem(2) <= shift_mem(1) XOR shift_mem(31);
                        shift_mem(3) <= shift_mem(2);
                        shift_mem(4) <= shift_mem(3) XOR shift_mem(31);
                        shift_mem(5) <= shift_mem(4) XOR shift_mem(31);
                        shift_mem(6) <= shift_mem(5);
                        shift_mem(7) <= shift_mem(6) XOR shift_mem(31);
                        shift_mem(8) <= shift_mem(7) XOR shift_mem(31);
                        shift_mem(9) <= shift_mem(8);
                        shift_mem(10) <= shift_mem(9) XOR shift_mem(31);
                        shift_mem(11) <= shift_mem(10) XOR shift_mem(31);
                        shift_mem(12) <= shift_mem(11) XOR shift_mem(31);
                        shift_mem(13) <= shift_mem(12);
                        shift_mem(14) <= shift_mem(13);
                        shift_mem(15) <= shift_mem(14);
                        shift_mem(16) <= shift_mem(15) XOR shift_mem(31);
                        shift_mem(17) <= shift_mem(16);
                        shift_mem(18) <= shift_mem(17);
                        shift_mem(19) <= shift_mem(18);
                        shift_mem(20) <= shift_mem(19);
                        shift_mem(21) <= shift_mem(20);
                        shift_mem(22) <= shift_mem(21) XOR shift_mem(31);
                        shift_mem(23) <= shift_mem(22) XOR shift_mem(31);
                        shift_mem(24) <= shift_mem(23);
                        shift_mem(25) <= shift_mem(24);
                        shift_mem(26) <= shift_mem(25) XOR shift_mem(31);
                        shift_mem(27) <= shift_mem(26);
                        shift_mem(28) <= shift_mem(27);
                        shift_mem(29) <= shift_mem(28);
                        shift_mem(30) <= shift_mem(29);
                        shift_mem(31) <= shift_mem(30);
                        END IF;
            
                WHEN CHECK_FCS =>
                    IF shift_mem = (shift_mem'RANGE => '0') THEN
                        FCS_ERROR <= '0';
                    ELSE
                        FCS_ERROR <= '1';
                    END IF;

                WHEN error_check =>
                    FCS_ERROR <= '0'; -- Reset for next frame

                WHEN OTHERS =>
                    NULL;
            END CASE;
        END IF;
    END PROCESS;
END ARCHITECTURE;