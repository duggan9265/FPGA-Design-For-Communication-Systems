-- vhdl-linter-disable type-resolved
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIFO_WRITE_CONTROL is
    port (
        WCLK : in std_logic;
        RST : in std_logic;
        WRITE_ENABLE : in std_logic_vector(0 downto 0);
        RPTR_SYNC : in unsigned(4 downto 0); --rd pointer that comes from the sync
        --FIFO_OCCU_IN : out std_logic_vector(4 downto 0);
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
    signal fifo_size : integer;
    signal write_enable_sig : std_logic_vector(0 downto 0);

begin

    fsm_process : process (WCLK) --asyn reset
    begin
        if rising_edge(WCLK) then
            if RST = '0' then --reset active low
                --WPTR <= (others => '0');
                wr_ptr_grey_code <= (others => '0');
                -- wr_ptr_sig <= (others => '0');
            else
                wr_ptr_grey_code(4) <= wr_ptr_sig(4); -- Binary code to grey code
                wr_ptr_grey_code(3) <= wr_ptr_sig(4) xor (wr_ptr_sig(3));
                wr_ptr_grey_code(2) <= wr_ptr_sig(3) xor (wr_ptr_sig(2));
                wr_ptr_grey_code(1) <= wr_ptr_sig(2) xor (wr_ptr_sig(1));
                wr_ptr_grey_code(0) <= wr_ptr_sig(1) xor (wr_ptr_sig(0));
                
                if WRITE_ENABLE(0) = '1' and full_sig = '0' then --don't write to full memory
                    wr_ptr_sig <= wr_ptr_sig + 1;
                    write_enable_sig <= (others => '1');
                elsif wr_ptr_sig = 31 then
                    wr_ptr_sig <= (others => '0');
                end if;

                --Check if full if raddr=waddr
                if (wr_ptr_sig(3 downto 0) = RPTR_SYNC(3 downto 0)) and (wr_ptr_sig(4) /= RPTR_SYNC(4)) then 
                    fifo_size <= to_integer(wr_ptr_sig) - to_integer(RPTR_SYNC);
                    if fifo_size = 16 then

                        full_sig <= '1'; -- FIFO is full
                    else
                        full_sig <= '0'; -- FIFO is not full
                    end if;
                end if;
            end if;
        end if;
    end process;
    WPTR <= wr_ptr_grey_code; -- WPTR is now in grey code. Sent to write_pointer_sync for sync
    FULL <= full_sig;
    WADDR <= (wr_ptr_sig(3 downto 0)); -- sent to the Dual-port memory
    WEN <= write_enable_sig; --sent to the Dual-port memory
end architecture rtl;