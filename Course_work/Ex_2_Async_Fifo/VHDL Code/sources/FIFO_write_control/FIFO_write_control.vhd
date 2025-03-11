-- vhdl-linter-disable type-resolved
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIFO_WRITE_CONTROL is
    port (
        WCLK : in std_logic;
        RST : in std_logic;
        WRITE_ENABLE : in std_logic;
        FIFO_OCCU_IN : out std_logic_vector(4 downto 0);
        FULL : out std_logic
    );
end entity;

architecture FSM of FIFO_WRITE_CONTROL is
    begin
    end architecture fsm;