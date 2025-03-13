-- vhdl-linter-disable type-resolved component. component
library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- LIBRARY blk_mem_gen_v8_4_7;
-- USE blk_mem_gen_v8_4_7.blk_mem_gen_v8_4_7;

entity Async_FIFO is
    port (
        RST_top : in std_logic;
        WCLK_top : in std_logic;
        RCLK_top : in std_logic;
        WRITE_ENABLE_TOP : in std_logic_vector(0 downto 0);
        READ_ENABLE_TOP : in std_logic_vector(0 downto 0);
        FULL_top : out std_logic; --output if memory is full
        EMPTY_top : out std_logic; -- output if memory is empty
        WRITE_DATA_IN_top : in std_logic_vector(7 downto 0);
        WRITE_DATA_OUT_top : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of Async_FIFO is

    -- Declare the component
    COMPONENT blk_mem_gen_0
        PORT (
            clka   : IN std_logic;
            wea    : IN std_logic_vector(0 DOWNTO 0);
            addra  : IN std_logic_vector(3 DOWNTO 0);
            dina   : IN std_logic_vector(7 DOWNTO 0);
            clkb   : IN std_logic;
            enb    : IN std_logic;
            addrb  : IN std_logic_vector(3 DOWNTO 0);
            doutb  : OUT std_logic_vector(7 DOWNTO 0)
        );
    END COMPONENT;
    
    -- FIFO_WRITE_CONTROL SIGNALS.
    signal wen_sig : std_logic_vector(0 downto 0); -- write enable from FIFO_WRITE_Control
     --write address from FIFO_WRITE_Control
    signal wr_pointer_sig : unsigned(4 downto 0); --write address from FIFO_WRITE_Control are bits (3 downto 0)
    signal wr_addr_a : unsigned(3 downto 0);
    signal wr_pointer_sync : unsigned(4 downto 0);

    --FIFO_READ_CONTROL SIGNALS.
    signal ren_sig : std_logic; -- write enable from FIFO_READ_CONTROL
    signal rd_pointer_sig : unsigned(4 downto 0);
    signal rd_addr_b : unsigned(3 downto 0);
    signal rd_pointer_sync : unsigned(4 downto 0);

begin

    Fifo_write_control_inst : entity work.FIFO_write_control
    port map(
        WCLK => WCLK_top,
        RST => RST_top,
        WRITE_ENABLE => WRITE_ENABLE_TOP,
        RPTR_SYNC => rd_pointer_sync,  --Input from Read_pointer_sync. Synchronised read pointer.
        FULL => FULL_top,
        WPTR => wr_pointer_sig, --Write pointer goes to the sync
        WEN => wen_sig, -- goes to block_mem via sig wen_sig in async_FIFO
        WADDR => wr_addr_a -- Output to addra of Memory (Write Address).

    );
    
    Dual_port_memory_inst : blk_mem_gen_0 -- vhdl-linter-disable-line not-declared

    port map(
        clka => WCLK_top,
        wea => wen_sig, -- write enable from FIFO_WRITE_Control 
        addra => std_logic_vector(wr_addr_a), -- write address from FIFO_WRITE_Control
        dina => WRITE_DATA_IN_top,
        clkb => RCLK_top,
        enb => ren_sig, -- write enable from FIFO_READ_CONTROL
        addrb => std_logic_vector(rd_addr_b), --read address from FIFO_READ_CONTROL
        doutb => WRITE_DATA_OUT_top
    );

    Fifo_read_control_inst : entity work.FIFO_read_control -- vhdl-linter-disable-line not-declared
    port map(
        RCLK => RCLK_top,
        RST => RST_top,
        READ_ENABLE => READ_ENABLE_TOP, -- read enable from TOP
        REN => ren_sig, -- write enable to BLOCK_MEM
        WPTR_SYNC => wr_pointer_sync, -- Input sig from WRITE_POINTER_SYNC. To determine occupancy and empty/full. 
        EMPTY => EMPTY_top, -- Output sig. Goes to TOP
        RPTR => rd_pointer_sig, -- output sig to Read_pointer_sync entity. Signal to be synchronised with wr_pointer_sig
        RADDR => rd_addr_b  -- Output sig to Dual port memory. Read address.
        
    );

    Write_pointer_sync_inst : entity work.write_pointer_sync
    port map( 
            RCLK => RCLK_top,
            --WCLK => WCLK_top,
            RST => RST_top,
            WPTR => wr_pointer_sig,         
            WRITE_POINTER_SYNC => wr_pointer_sync
    );

    Read_pointer_sync_inst : entity work.read_pointer_sync
    port map( 
            --RCLK => RCLK_top,
            WCLK => WCLK_top,
            RST => RST_top,
            RPTR => rd_pointer_sig, -- input from FIFO_read_control.         
            READ_POINTER_SYNC => rd_pointer_sync -- Output to FIFO_write_control. Synchronised read_pointer.
    );

end architecture rtl;