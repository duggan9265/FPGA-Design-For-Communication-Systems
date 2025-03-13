-- vhdl-linter-disable type-resolved
library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity write_pointer_sync is
    port (
        RCLK : in std_logic;
        WCLK : in std_logic;
        --RST : in std_logic;
        WPTR : in unsigned(4 downto 0);
        WRITE_POINTER_SYNC : out unsigned(4 downto 0)

    );
end entity;

architecture rtl of write_pointer_sync is
    signal wptr_ff_1 : unsigned(4 downto 0);
    signal wptr_ff_2 : unsigned(4 downto 0);
    signal wptr_ff_3 : unsigned(4 downto 0);
    signal grey2binary : unsigned(4 downto 0);

begin
    -- rst_process : process(RST)
    -- begin
    --     if rst = '0' then
    --         WRITE_POINTER_SYNC <= (others => '0');
    --     end if;
    -- end process;

    first_FF_process : process (WCLK)
    begin
        if rising_edge(WCLK) then
            wptr_ff_1 <= WPTR;
        end if;
    end process;

    second_FF_process : process (RCLK)
    begin
        if rising_edge(RCLK) then
            wptr_ff_2 <= wptr_ff_1;
            wptr_ff_3 <= wptr_ff_2;

            -- MSB of binary is the same as MSB of gray code
            grey2binary(4) <= wptr_ff_3(4);
            -- Other bits of binary are the XOR of corresponding gray code and previous binary bit
            grey2binary(3) <= wptr_ff_3(3) xor wptr_ff_3(4);
            grey2binary(2) <= wptr_ff_3(2) xor wptr_ff_3(3);
            grey2binary(1) <= wptr_ff_3(1) xor wptr_ff_3(2);
            grey2binary(0) <= wptr_ff_3(0) xor wptr_ff_3(1);
        end if;
        WRITE_POINTER_SYNC <= grey2binary;
    end process;

end architecture rtl;