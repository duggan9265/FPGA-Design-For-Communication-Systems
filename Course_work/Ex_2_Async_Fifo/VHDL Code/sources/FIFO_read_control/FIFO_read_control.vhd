-- vhdl-linter-disable type-resolved
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIFO_READ_CONTROL is
    port (
        RCLK : in std_logic;
        RST : in std_logic;
        READ_ENABLE : in std_logic_vector(0 downto 0);
        WPTR_SYNC : in unsigned(4 downto 0); --wp pointer that comes from the sync
        --FIFO_OCCU_OUT : out std_logic_vector(4 downto 0);
        EMPTY : out std_logic;
        RPTR : out unsigned(4 downto 0); --Write pointer goes to the sync i.e. grey-coded
        REN : out std_logic; -- goes to block_mem via sig wen_sig in async_FIFO
        RADDR : out unsigned(3 downto 0) -- write address. Goes to block_mem via signal waddr_sig in async_FIFO
    );
end entity;

architecture rtl of FIFO_READ_CONTROL is

    signal rd_ptr_grey_code : unsigned(4 downto 0);
    signal rd_ptr_sig : unsigned(4 downto 0);
    signal empty_sig : std_logic;
    --signal fifo_size : integer;
    signal rd_enable_out : std_logic;

begin

    fsm_process : process (RCLK) --asyn reset
    begin
        if rising_edge(RCLK) then
            if RST = '0' then --reset active low
                --RPTR <= (others => '0');
                --rd_ptr_grey_code <= (others => '0');
                rd_ptr_sig <= (others => '0');

            else

                rd_ptr_grey_code(4) <= rd_ptr_sig(4); -- Binary code to grey code
                rd_ptr_grey_code(3) <= rd_ptr_sig(4) xor (rd_ptr_sig(3));
                rd_ptr_grey_code(2) <= rd_ptr_sig(3) xor (rd_ptr_sig(2));
                rd_ptr_grey_code(1) <= rd_ptr_sig(2) xor (rd_ptr_sig(1));
                rd_ptr_grey_code(0) <= rd_ptr_sig(1) xor (rd_ptr_sig(0));
                

                if READ_ENABLE(0) = '1' and empty_sig = '0' then --don't write to full memory
                    rd_ptr_sig <= rd_ptr_sig + 1;
                    rd_enable_out <= '1';
                elsif rd_ptr_sig = 31 then
                    rd_ptr_sig <= (others => '0');
                end if;

                if rd_ptr_sig(3 downto 0) = WPTR_SYNC(3 downto 0) then -- raddr=waddr
                    if rd_ptr_sig(4) = WPTR_SYNC(4) then
                        EMPTY_sig <= '1'; -- FIFO is empty when read and write pointers MSB's are equal
                    else
                        EMPTY_sig <= '0'; -- FIFO is not empty
                    end if;
                end if;
            end if;
        end if;
    end process;
    RADDR <= (rd_ptr_sig(3 downto 0));
    RPTR <= rd_ptr_grey_code; -- RPTR is now in grey code.
    EMPTY <= empty_sig;
    REN <= rd_enable_out;
end architecture rtl;