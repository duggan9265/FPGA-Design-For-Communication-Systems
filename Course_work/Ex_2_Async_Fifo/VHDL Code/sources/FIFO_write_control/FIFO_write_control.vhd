-- vhdl-linter-disable type-resolved
-- Author Daniel Duggan
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIFO_WRITE_CONTROL is
    port (
        WCLK : in std_logic;
        RST : in std_logic;
        WRITE_ENABLE : in std_logic_vector(0 downto 0);
        RPTR_SYNC : in unsigned(4 downto 0); --rd pointer that comes from the sync
        FULL : out std_logic;
        WPTR : out unsigned(4 downto 0); --Write pointer goes to the sync i.e. grey-coded
        WEN : out std_logic_vector(0 downto 0); -- goes to block_mem via sig wen_sig in async_FIFO
        WADDR : out unsigned(3 downto 0) -- write address. Goes to block_mem via signal waddr_sig in async_FIFO
    );
end entity;

architecture rtl of FIFO_WRITE_CONTROL is

    signal wr_ptr_grey_code : unsigned(4 downto 0);
    signal wr_ptr_sig : unsigned(4 downto 0);
    signal full_sig : std_logic;


begin

    write_control_process : process (WCLK,RST) --asyn reset
    begin
            if RST = '0' then --reset active low
                wr_ptr_grey_code <= (others => '0');
                wr_ptr_sig <= (others => '0');
                


            
            elsif rising_edge(WCLK) then

                wr_ptr_grey_code(4) <= wr_ptr_sig(4); -- Binary code to grey code
                wr_ptr_grey_code(3) <= wr_ptr_sig(4) xor (wr_ptr_sig(3));
                wr_ptr_grey_code(2) <= wr_ptr_sig(3) xor (wr_ptr_sig(2));
                wr_ptr_grey_code(1) <= wr_ptr_sig(2) xor (wr_ptr_sig(1));
                wr_ptr_grey_code(0) <= wr_ptr_sig(1) xor (wr_ptr_sig(0));
                
                if WRITE_ENABLE(0) = '1' and full_sig = '0' then --don't write to full memory
                    wr_ptr_sig <= (wr_ptr_sig + 1);
               end if;
               WPTR <= wr_ptr_grey_code; -- WPTR is now in grey code. Sent to write_pointer_sync for sync
            end if;
    end process;

    full_sig <= '1' when (wr_ptr_sig - RPTR_SYNC = 15) else '0';


    --WPTR <= wr_ptr_grey_code; -- WPTR is now in grey code. Sent to write_pointer_sync for sync
    FULL <= full_sig;
    WADDR <= (wr_ptr_sig(3 downto 0)); -- sent to the Dual-port memory
    WEN <=  (others =>'1') when (WRITE_ENABLE(0)='1' AND full_sig = '0') else (others => '0'); --sent to the Dual-port memory '1' when (rd_ptr_sig_delay = WPTR_SYNC) else '0';
end architecture rtl;