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
    signal rd_enable_out : std_logic;

begin

    FIFO_read_control_process : process (RCLK, RST) --asyn reset
    begin
        if RST = '0' then --reset active low
            --RPTR <= (others => '0');
            rd_ptr_grey_code <= (others => '0');-- this gives multiple load error
            rd_enable_out <= '0';
            rd_ptr_sig <= (others => '0'); --this gives multiple load error

        elsif rising_edge(RCLK) then

            rd_ptr_grey_code(4) <= rd_ptr_sig(4); -- Binary code to grey code
            rd_ptr_grey_code(3) <= rd_ptr_sig(4) xor (rd_ptr_sig(3));
            rd_ptr_grey_code(2) <= rd_ptr_sig(3) xor (rd_ptr_sig(2));
            rd_ptr_grey_code(1) <= rd_ptr_sig(2) xor (rd_ptr_sig(1));
            rd_ptr_grey_code(0) <= rd_ptr_sig(1) xor (rd_ptr_sig(0));

            if READ_ENABLE(0) = '1' and empty_sig = '0' then --don't read from empty memory
                rd_ptr_sig <= (rd_ptr_sig + 1); --unsigned so naturally wraps to 0                   
                rd_enable_out <= '1';
            else
                rd_enable_out <= '0';
            end if;
        end if;

    end process;

    empty_sig <= '1' when (rd_ptr_sig = WPTR_SYNC) else '0'; --Check if empty or not. Uses synced wr_ptr.
    RADDR <= (rd_ptr_sig(3 downto 0));
    RPTR <= rd_ptr_grey_code; -- RPTR is now in grey code.
    EMPTY <= empty_sig;
    REN <= rd_enable_out;
end architecture rtl; --all 5 bits and equal, empty, all 5 bits and difference is 16 is full.