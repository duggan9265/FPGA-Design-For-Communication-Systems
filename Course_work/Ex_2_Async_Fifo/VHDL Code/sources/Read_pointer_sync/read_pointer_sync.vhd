-- vhdl-linter-disable type-resolved
-- Author Daniel Duggan
library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity read_pointer_sync is
    port (
        --RCLK : in std_logic;
        WCLK : in std_logic;
        RST : in std_logic;
        RPTR : in unsigned(4 downto 0);
        READ_POINTER_SYNC : out unsigned(4 downto 0)
    );
end entity;

architecture rtl of read_pointer_sync is
    signal rptr_ff_1 : unsigned(4 downto 0);
    signal rptr_ff_2 : unsigned(4 downto 0);

begin
    second_FF_process : process (WCLK, RST)
        variable grey2binary : unsigned(4 downto 0);
    begin
        if RST = '0' then
            READ_POINTER_SYNC <= (others => '0');
            rptr_ff_1 <= (others => '0');
            rptr_ff_2 <= (others => '0');
            READ_POINTER_SYNC <= (others => '0');

        elsif rising_edge(WCLK) then

            rptr_ff_1 <= RPTR;
            rptr_ff_2 <= rptr_ff_1;
    
            grey2binary(4) := rptr_ff_2(4);
            grey2binary(3) := rptr_ff_2(3) xor grey2binary(4);
            grey2binary(2) := rptr_ff_2(2) xor grey2binary(3);
            grey2binary(1) := rptr_ff_2(1) xor grey2binary(2);
            grey2binary(0) := rptr_ff_2(0) xor grey2binary(1);
           READ_POINTER_SYNC <= grey2binary; -- Needs to be inside process so it happens on rising_edge of clock!
        end if;

    end process;
end architecture rtl;