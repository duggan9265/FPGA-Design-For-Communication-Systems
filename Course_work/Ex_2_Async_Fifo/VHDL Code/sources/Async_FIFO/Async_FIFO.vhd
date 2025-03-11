-- vhdl-linter-disable type-resolved component
library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
LIBRARY blk_mem_gen_v8_4_7;
USE blk_mem_gen_v8_4_7.blk_mem_gen_v8_4_7;

entity Async_FIFO is
    port (
        RST : in std_logic;
        WCLK : in std_logic;
        RCLK : in std_logic;
        WRITE_ENABLE : in std_logic;
        READ_ENABLE : in std_logic;
        FIFO_OCCU_IN : out std_logic_vector(4 downto 0);
        FIFO_OCCU_OUT : out std_logic_vector(4 downto 0);
        WRITE_DATA_IN : in std_logic_vector(7 downto 0);
        WRITE_DATA_OUT : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of Async_FIFO is
    
    -- FIFO_WRITE_CONTROL SIGNALS.
    signal wen : std_logic_vector(0 downto 0); -- write enable from FIFO_WRITE_Control
    signal waddr : std_logic_vector(3 downto 0); --write address from FIFO_WRITE_Control

    --FIFO_READ_CONTROL SIGNALS
    signal ren : std_logic; -- write enable from FIFO_READ_CONTROL
    signal raddr : std_logic_vector(3 downto 0); --write address from FIFO_READ_CONTROL
begin
    ------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG.
    Dual_port_memory : blk_mem_gen_0

    port map(
        clka => WCLK,
        wea => wen, -- write enable from FIFO_WRITE_Control 
        addra => waddr, -- write address from FIFO_WRITE_Control
        dina => WRITE_DATA_IN,
        clkb => RCLK,
        enb => ren, -- write enable from FIFO_READ_CONTROL
        addrb => raddr, --write address from FIFO_READ_CONTROL
        doutb => WRITE_DATA_OUT
    );

end architecture rtl;