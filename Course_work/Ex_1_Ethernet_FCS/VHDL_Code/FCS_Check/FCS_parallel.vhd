-- Author Daniel Duggan
-- vhdl-linter-disable type-resolved
LIBRARY IEEE;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fcs_check_parallel_FSM IS

    GENERIC (
        Depth : INTEGER := 32
    );

    PORT (

        CLK : IN STD_LOGIC; -- system clock
        RST : IN STD_LOGIC; -- asynchronous reset
        START_OF_FRAME : IN STD_LOGIC; -- arrival of the first byte.
        END_OF_FRAME : IN STD_LOGIC; -- arrival of the first byte in FCS.
        DATA_IN : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- input data.
        FCS_ERROR : OUT STD_LOGIC -- indicates an error.
    );
END fcs_check_parallel_FSM;

ARCHITECTURE fsm OF fcs_check_parallel_FSM IS
    TYPE fsm_fcs_type IS
    (idle, data_recieve, fcs_recieve, check_fcs, error_check);
    SIGNAL state, next_state : fsm_fcs_type; --state, next_state can take on all values inside fsm_fcs_type
    SIGNAL byte_count : unsigned(6 DOWNTO 0);
    SIGNAL shift_mem : STD_LOGIC_VECTOR(DEPTH - 1 DOWNTO 0);
    SIGNAL check_data : STD_LOGIC_VECTOR(7 DOWNTO 0); -- For debug purposes only
BEGIN
    fsm_process : PROCESS (state, START_OF_FRAME, END_OF_FRAME, byte_count)
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
                IF byte_count = 64 THEN
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
            byte_count <= (OTHERS => '0');
        ELSIF rising_edge(CLK) THEN
            state <= next_state;

            CASE state IS
                WHEN idle =>
                    shift_mem <= (OTHERS => '0');
                    byte_count <= (OTHERS => '0');
                    FCS_ERROR <= '0';

                WHEN data_recieve =>

                    IF byte_count < 3 THEN
                        check_data <= NOT DATA_IN;
                        shift_mem(0) <= shift_mem(24) XOR shift_mem(30) XOR NOT(DATA_IN(7));
                        shift_mem(1) <= shift_mem(24) XOR shift_mem(25) XOR shift_mem(30) XOR shift_mem(31) XOR NOT(DATA_IN(6));
                        shift_mem(2) <= shift_mem(24) XOR shift_mem(25) XOR shift_mem(26) XOR shift_mem(30) XOR shift_mem(31) XOR NOT(DATA_IN(5));
                        shift_mem(3) <= shift_mem(25) XOR shift_mem(26) XOR shift_mem(27) XOR shift_mem(31) XOR NOT(DATA_IN(4));
                        shift_mem(4) <= shift_mem(24) XOR shift_mem(26) XOR shift_mem(27) XOR shift_mem(28) XOR shift_mem(30) XOR NOT(DATA_IN(3));
                        shift_mem(5) <= shift_mem(24) XOR shift_mem(25) XOR shift_mem(27) XOR shift_mem(28) XOR shift_mem(29) XOR shift_mem(30) XOR shift_mem(31) XOR NOT(DATA_IN(2));
                        shift_mem(6) <= shift_mem(25) XOR shift_mem(26) XOR shift_mem(28) XOR shift_mem(29) XOR shift_mem(30) XOR shift_mem(31) XOR NOT(DATA_IN(1));
                        shift_mem(7) <= shift_mem(24) XOR shift_mem(26) XOR shift_mem(27) XOR shift_mem(29) XOR shift_mem(31) XOR NOT(DATA_IN(0));
                        shift_mem(8) <= shift_mem(0) XOR shift_mem(24) XOR shift_mem(25) XOR shift_mem(27) XOR shift_mem(28);
                        shift_mem(9) <= shift_mem(1) XOR shift_mem(25) XOR shift_mem(26) XOR shift_mem(28) XOR shift_mem(29);
                        shift_mem(10) <= shift_mem(2) XOR shift_mem(24) XOR shift_mem(26) XOR shift_mem(27) XOR shift_mem(29);
                        shift_mem(11) <= shift_mem(3) XOR shift_mem(24) XOR shift_mem(25) XOR shift_mem(27) XOR shift_mem(28);
                        shift_mem(12) <= shift_mem(4) XOR shift_mem(24) XOR shift_mem(25) XOR shift_mem(26) XOR shift_mem(28) XOR shift_mem(29) XOR shift_mem(30);
                        shift_mem(13) <= shift_mem(5) XOR shift_mem(25) XOR shift_mem(26) XOR shift_mem(27) XOR shift_mem(29) XOR shift_mem(30) XOR shift_mem(31);
                        shift_mem(14) <= shift_mem(6) XOR shift_mem(26) XOR shift_mem(27) XOR shift_mem(28) XOR shift_mem(30) XOR shift_mem(31);
                        shift_mem(15) <= shift_mem(7) XOR shift_mem(27) XOR shift_mem(28) XOR shift_mem(29) XOR shift_mem(31);
                        shift_mem(16) <= shift_mem(8) XOR shift_mem(24) XOR shift_mem(28) XOR shift_mem(29);
                        shift_mem(17) <= shift_mem(9) XOR shift_mem(25) XOR shift_mem(29) XOR shift_mem(30);
                        shift_mem(18) <= shift_mem(10) XOR shift_mem(26) XOR shift_mem(30) XOR shift_mem(31);
                        shift_mem(19) <= shift_mem(11) XOR shift_mem(27) XOR shift_mem(31);
                        shift_mem(20) <= shift_mem(12) XOR shift_mem(28);
                        shift_mem(21) <= shift_mem(13) XOR shift_mem(29);
                        shift_mem(22) <= shift_mem(14) XOR shift_mem(24);
                        shift_mem(23) <= shift_mem(15) XOR shift_mem(24) XOR shift_mem(25) XOR shift_mem(30);
                        shift_mem(24) <= shift_mem(16) XOR shift_mem(25) XOR shift_mem(26) XOR shift_mem(31);
                        shift_mem(25) <= shift_mem(17) XOR shift_mem(26) XOR shift_mem(27);
                        shift_mem(26) <= shift_mem(18) XOR shift_mem(24) XOR shift_mem(27) XOR shift_mem(28) XOR shift_mem(30);
                        shift_mem(27) <= shift_mem(19) XOR shift_mem(25) XOR shift_mem(28) XOR shift_mem(29) XOR shift_mem(31);
                        shift_mem(28) <= shift_mem(20) XOR shift_mem(26) XOR shift_mem(29) XOR shift_mem(30);
                        shift_mem(29) <= shift_mem(21) XOR shift_mem(27) XOR shift_mem(30) XOR shift_mem(31);
                        shift_mem(30) <= shift_mem(22) XOR shift_mem(28) XOR shift_mem(31);
                        shift_mem(31) <= shift_mem(23) XOR shift_mem(29);

                    ELSE
                        check_data <= DATA_IN;
                        shift_mem(0) <= shift_mem(24) XOR shift_mem(30) XOR DATA_IN(7);
                        shift_mem(1) <= shift_mem(24) XOR shift_mem(25) XOR shift_mem(30) XOR shift_mem(31) XOR DATA_IN(6);
                        shift_mem(2) <= shift_mem(24) XOR shift_mem(25) XOR shift_mem(26) XOR shift_mem(30) XOR shift_mem(31) XOR DATA_IN(5);
                        shift_mem(3) <= shift_mem(25) XOR shift_mem(26) XOR shift_mem(27) XOR shift_mem(31) XOR DATA_IN(4);
                        shift_mem(4) <= shift_mem(24) XOR shift_mem(26) XOR shift_mem(27) XOR shift_mem(28) XOR shift_mem(30) XOR DATA_IN(3);
                        shift_mem(5) <= shift_mem(24) XOR shift_mem(25) XOR shift_mem(27) XOR shift_mem(28) XOR shift_mem(29) XOR shift_mem(30) XOR shift_mem(31) XOR DATA_IN(2);
                        shift_mem(6) <= shift_mem(25) XOR shift_mem(26) XOR shift_mem(28) XOR shift_mem(29) XOR shift_mem(30) XOR shift_mem(31) XOR DATA_IN(1);
                        shift_mem(7) <= shift_mem(24) XOR shift_mem(26) XOR shift_mem(27) XOR shift_mem(29) XOR shift_mem(31) XOR DATA_IN(0);
                        shift_mem(8) <= shift_mem(0) XOR shift_mem(24) XOR shift_mem(25) XOR shift_mem(27) XOR shift_mem(28);
                        shift_mem(9) <= shift_mem(1) XOR shift_mem(25) XOR shift_mem(26) XOR shift_mem(28) XOR shift_mem(29);
                        shift_mem(10) <= shift_mem(2) XOR shift_mem(24) XOR shift_mem(26) XOR shift_mem(27) XOR shift_mem(29);
                        shift_mem(11) <= shift_mem(3) XOR shift_mem(24) XOR shift_mem(25) XOR shift_mem(27) XOR shift_mem(28);
                        shift_mem(12) <= shift_mem(4) XOR shift_mem(24) XOR shift_mem(25) XOR shift_mem(26) XOR shift_mem(28) XOR shift_mem(29) XOR shift_mem(30);
                        shift_mem(13) <= shift_mem(5) XOR shift_mem(25) XOR shift_mem(26) XOR shift_mem(27) XOR shift_mem(29) XOR shift_mem(30) XOR shift_mem(31);
                        shift_mem(14) <= shift_mem(6) XOR shift_mem(26) XOR shift_mem(27) XOR shift_mem(28) XOR shift_mem(30) XOR shift_mem(31);
                        shift_mem(15) <= shift_mem(7) XOR shift_mem(27) XOR shift_mem(28) XOR shift_mem(29) XOR shift_mem(31);
                        shift_mem(16) <= shift_mem(8) XOR shift_mem(24) XOR shift_mem(28) XOR shift_mem(29);
                        shift_mem(17) <= shift_mem(9) XOR shift_mem(25) XOR shift_mem(29) XOR shift_mem(30);
                        shift_mem(18) <= shift_mem(10) XOR shift_mem(26) XOR shift_mem(30) XOR shift_mem(31);
                        shift_mem(19) <= shift_mem(11) XOR shift_mem(27) XOR shift_mem(31);
                        shift_mem(20) <= shift_mem(12) XOR shift_mem(28);
                        shift_mem(21) <= shift_mem(13) XOR shift_mem(29);
                        shift_mem(22) <= shift_mem(14) XOR shift_mem(24);
                        shift_mem(23) <= shift_mem(15) XOR shift_mem(24) XOR shift_mem(25) XOR shift_mem(30);
                        shift_mem(24) <= shift_mem(16) XOR shift_mem(25) XOR shift_mem(26) XOR shift_mem(31);
                        shift_mem(25) <= shift_mem(17) XOR shift_mem(26) XOR shift_mem(27);
                        shift_mem(26) <= shift_mem(18) XOR shift_mem(24) XOR shift_mem(27) XOR shift_mem(28) XOR shift_mem(30);
                        shift_mem(27) <= shift_mem(19) XOR shift_mem(25) XOR shift_mem(28) XOR shift_mem(29) XOR shift_mem(31);
                        shift_mem(28) <= shift_mem(20) XOR shift_mem(26) XOR shift_mem(29) XOR shift_mem(30);
                        shift_mem(29) <= shift_mem(21) XOR shift_mem(27) XOR shift_mem(30) XOR shift_mem(31);
                        shift_mem(30) <= shift_mem(22) XOR shift_mem(28) XOR shift_mem(31);
                        shift_mem(31) <= shift_mem(23) XOR shift_mem(29);
                    END IF;
                    byte_count <= byte_count + 1;

                WHEN fcs_recieve =>

                    IF byte_count > 61 THEN -- XOR last 32 bits (bytes 60,61,62)
                        check_data <= NOT DATA_IN;
                        byte_count <= byte_count + 1;
                        shift_mem(0) <= shift_mem(24) XOR shift_mem(30) XOR NOT(DATA_IN(7));
                        shift_mem(1) <= shift_mem(24) XOR shift_mem(25) XOR shift_mem(30) XOR shift_mem(31) XOR NOT(DATA_IN(6));
                        shift_mem(2) <= shift_mem(24) XOR shift_mem(25) XOR shift_mem(26) XOR shift_mem(30) XOR shift_mem(31) XOR NOT(DATA_IN(5));
                        shift_mem(3) <= shift_mem(25) XOR shift_mem(26) XOR shift_mem(27) XOR shift_mem(31) XOR NOT(DATA_IN(4));
                        shift_mem(4) <= shift_mem(24) XOR shift_mem(26) XOR shift_mem(27) XOR shift_mem(28) XOR shift_mem(30) XOR NOT(DATA_IN(3));
                        shift_mem(5) <= shift_mem(24) XOR shift_mem(25) XOR shift_mem(27) XOR shift_mem(28) XOR shift_mem(29) XOR shift_mem(30) XOR shift_mem(31) XOR NOT(DATA_IN(2));
                        shift_mem(6) <= shift_mem(25) XOR shift_mem(26) XOR shift_mem(28) XOR shift_mem(29) XOR shift_mem(30) XOR shift_mem(31) XOR NOT(DATA_IN(1));
                        shift_mem(7) <= shift_mem(24) XOR shift_mem(26) XOR shift_mem(27) XOR shift_mem(29) XOR shift_mem(31) XOR NOT(DATA_IN(0));
                        shift_mem(8) <= shift_mem(0) XOR shift_mem(24) XOR shift_mem(25) XOR shift_mem(27) XOR shift_mem(28);
                        shift_mem(9) <= shift_mem(1) XOR shift_mem(25) XOR shift_mem(26) XOR shift_mem(28) XOR shift_mem(29);
                        shift_mem(10) <= shift_mem(2) XOR shift_mem(24) XOR shift_mem(26) XOR shift_mem(27) XOR shift_mem(29);
                        shift_mem(11) <= shift_mem(3) XOR shift_mem(24) XOR shift_mem(25) XOR shift_mem(27) XOR shift_mem(28);
                        shift_mem(12) <= shift_mem(4) XOR shift_mem(24) XOR shift_mem(25) XOR shift_mem(26) XOR shift_mem(28) XOR shift_mem(29) XOR shift_mem(30);
                        shift_mem(13) <= shift_mem(5) XOR shift_mem(25) XOR shift_mem(26) XOR shift_mem(27) XOR shift_mem(29) XOR shift_mem(30) XOR shift_mem(31);
                        shift_mem(14) <= shift_mem(6) XOR shift_mem(26) XOR shift_mem(27) XOR shift_mem(28) XOR shift_mem(30) XOR shift_mem(31);
                        shift_mem(15) <= shift_mem(7) XOR shift_mem(27) XOR shift_mem(28) XOR shift_mem(29) XOR shift_mem(31);
                        shift_mem(16) <= shift_mem(8) XOR shift_mem(24) XOR shift_mem(28) XOR shift_mem(29);
                        shift_mem(17) <= shift_mem(9) XOR shift_mem(25) XOR shift_mem(29) XOR shift_mem(30);
                        shift_mem(18) <= shift_mem(10) XOR shift_mem(26) XOR shift_mem(30) XOR shift_mem(31);
                        shift_mem(19) <= shift_mem(11) XOR shift_mem(27) XOR shift_mem(31);
                        shift_mem(20) <= shift_mem(12) XOR shift_mem(28);
                        shift_mem(21) <= shift_mem(13) XOR shift_mem(29);
                        shift_mem(22) <= shift_mem(14) XOR shift_mem(24);
                        shift_mem(23) <= shift_mem(15) XOR shift_mem(24) XOR shift_mem(25) XOR shift_mem(30);
                        shift_mem(24) <= shift_mem(16) XOR shift_mem(25) XOR shift_mem(26) XOR shift_mem(31);
                        shift_mem(25) <= shift_mem(17) XOR shift_mem(26) XOR shift_mem(27);
                        shift_mem(26) <= shift_mem(18) XOR shift_mem(24) XOR shift_mem(27) XOR shift_mem(28) XOR shift_mem(30);
                        shift_mem(27) <= shift_mem(19) XOR shift_mem(25) XOR shift_mem(28) XOR shift_mem(29) XOR shift_mem(31);
                        shift_mem(28) <= shift_mem(20) XOR shift_mem(26) XOR shift_mem(29) XOR shift_mem(30);
                        shift_mem(29) <= shift_mem(21) XOR shift_mem(27) XOR shift_mem(30) XOR shift_mem(31);
                        shift_mem(30) <= shift_mem(22) XOR shift_mem(28) XOR shift_mem(31);
                        shift_mem(31) <= shift_mem(23) XOR shift_mem(29);

                    ELSE
                        check_data <= DATA_IN;
                        byte_count <= byte_count + 1;
                        shift_mem(0) <= shift_mem(24) XOR shift_mem(30) XOR DATA_IN(7);
                        shift_mem(1) <= shift_mem(24) XOR shift_mem(25) XOR shift_mem(30) XOR shift_mem(31) XOR DATA_IN(6);
                        shift_mem(2) <= shift_mem(24) XOR shift_mem(25) XOR shift_mem(26) XOR shift_mem(30) XOR shift_mem(31) XOR DATA_IN(5);
                        shift_mem(3) <= shift_mem(25) XOR shift_mem(26) XOR shift_mem(27) XOR shift_mem(31) XOR DATA_IN(4);
                        shift_mem(4) <= shift_mem(24) XOR shift_mem(26) XOR shift_mem(27) XOR shift_mem(28) XOR shift_mem(30) XOR DATA_IN(3);
                        shift_mem(5) <= shift_mem(24) XOR shift_mem(25) XOR shift_mem(27) XOR shift_mem(28) XOR shift_mem(29) XOR shift_mem(30) XOR shift_mem(31) XOR DATA_IN(2);
                        shift_mem(6) <= shift_mem(25) XOR shift_mem(26) XOR shift_mem(28) XOR shift_mem(29) XOR shift_mem(30) XOR shift_mem(31) XOR DATA_IN(1);
                        shift_mem(7) <= shift_mem(24) XOR shift_mem(26) XOR shift_mem(27) XOR shift_mem(29) XOR shift_mem(31) XOR DATA_IN(0);
                        shift_mem(8) <= shift_mem(0) XOR shift_mem(24) XOR shift_mem(25) XOR shift_mem(27) XOR shift_mem(28);
                        shift_mem(9) <= shift_mem(1) XOR shift_mem(25) XOR shift_mem(26) XOR shift_mem(28) XOR shift_mem(29);
                        shift_mem(10) <= shift_mem(2) XOR shift_mem(24) XOR shift_mem(26) XOR shift_mem(27) XOR shift_mem(29);
                        shift_mem(11) <= shift_mem(3) XOR shift_mem(24) XOR shift_mem(25) XOR shift_mem(27) XOR shift_mem(28);
                        shift_mem(12) <= shift_mem(4) XOR shift_mem(24) XOR shift_mem(25) XOR shift_mem(26) XOR shift_mem(28) XOR shift_mem(29) XOR shift_mem(30);
                        shift_mem(13) <= shift_mem(5) XOR shift_mem(25) XOR shift_mem(26) XOR shift_mem(27) XOR shift_mem(29) XOR shift_mem(30) XOR shift_mem(31);
                        shift_mem(14) <= shift_mem(6) XOR shift_mem(26) XOR shift_mem(27) XOR shift_mem(28) XOR shift_mem(30) XOR shift_mem(31);
                        shift_mem(15) <= shift_mem(7) XOR shift_mem(27) XOR shift_mem(28) XOR shift_mem(29) XOR shift_mem(31);
                        shift_mem(16) <= shift_mem(8) XOR shift_mem(24) XOR shift_mem(28) XOR shift_mem(29);
                        shift_mem(17) <= shift_mem(9) XOR shift_mem(25) XOR shift_mem(29) XOR shift_mem(30);
                        shift_mem(18) <= shift_mem(10) XOR shift_mem(26) XOR shift_mem(30) XOR shift_mem(31);
                        shift_mem(19) <= shift_mem(11) XOR shift_mem(27) XOR shift_mem(31);
                        shift_mem(20) <= shift_mem(12) XOR shift_mem(28);
                        shift_mem(21) <= shift_mem(13) XOR shift_mem(29);
                        shift_mem(22) <= shift_mem(14) XOR shift_mem(24);
                        shift_mem(23) <= shift_mem(15) XOR shift_mem(24) XOR shift_mem(25) XOR shift_mem(30);
                        shift_mem(24) <= shift_mem(16) XOR shift_mem(25) XOR shift_mem(26) XOR shift_mem(31);
                        shift_mem(25) <= shift_mem(17) XOR shift_mem(26) XOR shift_mem(27);
                        shift_mem(26) <= shift_mem(18) XOR shift_mem(24) XOR shift_mem(27) XOR shift_mem(28) XOR shift_mem(30);
                        shift_mem(27) <= shift_mem(19) XOR shift_mem(25) XOR shift_mem(28) XOR shift_mem(29) XOR shift_mem(31);
                        shift_mem(28) <= shift_mem(20) XOR shift_mem(26) XOR shift_mem(29) XOR shift_mem(30);
                        shift_mem(29) <= shift_mem(21) XOR shift_mem(27) XOR shift_mem(30) XOR shift_mem(31);
                        shift_mem(30) <= shift_mem(22) XOR shift_mem(28) XOR shift_mem(31);
                        shift_mem(31) <= shift_mem(23) XOR shift_mem(29);
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