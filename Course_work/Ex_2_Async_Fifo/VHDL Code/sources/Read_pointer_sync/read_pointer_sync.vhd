-- vhdl-linter-disable type-resolved
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
    signal grey2binary : unsigned(4 downto 0);

begin
    second_FF_process : process (WCLK,RST)
    begin
        if RST = '0' then
            READ_POINTER_SYNC <= (others => '0');
        
            elsif rising_edge(WCLK) then

            rptr_ff_1 <= RPTR;
            rptr_ff_2 <= rptr_ff_1;

            -- MSB of binary is the same as MSB of gray code
            grey2binary(4) <= rptr_ff_2(4);
            -- Other bits of binary are the XOR of corresponding gray code and previous binary bit
            grey2binary(3) <= rptr_ff_2(3) xor rptr_ff_2(4);
            grey2binary(2) <= rptr_ff_2(2) xor rptr_ff_2(3);
            grey2binary(1) <= rptr_ff_2(1) xor rptr_ff_2(2);
            grey2binary(0) <= rptr_ff_2(0) xor rptr_ff_2(1);
        end if;
    end process;
    READ_POINTER_SYNC <= grey2binary;
end architecture rtl;