-- vhdl-linter-disable type-resolved
-- Author Daniel Duggan
library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity write_pointer_sync is
    port (
        RCLK : in std_logic;
        --WCLK : in std_logic;
        RST : in std_logic;
        WPTR : in unsigned(4 downto 0);
        WRITE_POINTER_SYNC : out unsigned(4 downto 0)

    );
end entity;

architecture rtl of write_pointer_sync is
    signal wptr_ff_1 : unsigned(4 downto 0);
    signal wptr_ff_2 : unsigned(4 downto 0);
begin

    second_FF_process : process (RCLK, RST)
        variable grey2binary : unsigned(4 downto 0);
    begin
        if rst = '0' then
            WRITE_POINTER_SYNC <= (others => '0');
            wptr_ff_1 <= (others => '0');
            wptr_ff_2 <= (others => '0');
        elsif rising_edge(RCLK) then
            -- wptr_ff_0 <= WPTR;
            wptr_ff_1 <= WPTR;
            wptr_ff_2 <= wptr_ff_1;

            -- Grey code to binary code
            grey2binary(4) := wptr_ff_2(4);
            grey2binary(3) := wptr_ff_2(3) xor grey2binary(4);
            grey2binary(2) := wptr_ff_2(2) xor grey2binary(3);
            grey2binary(1) := wptr_ff_2(1) xor grey2binary(2);
            grey2binary(0) := wptr_ff_2(0) xor grey2binary(1);
            WRITE_POINTER_SYNC <= grey2binary; -- Needs to be inside process so it happens on rising_edge of clock!
        end if;
    end process; 
end architecture rtl;