library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo_synch is
    port (
        clk           : in  std_logic;
        rst           : in  std_logic;
        wr            : in  std_logic;
        rd            : in  std_logic;
        fifo_data_in  : in  std_logic_vector(7 downto 0);
        fifo_data_out : out std_logic_vector(7 downto 0);
        full          : out std_logic;
        empty         : out std_logic
    );
end fifo_synch;

architecture arch of fifo_synch is

    type fifo_array_type is array (0 to 3) of std_logic_vector(7 downto 0);
    signal fifo_memory : fifo_array_type := (others => (others => '0'));
    signal wr_ptr_reg : unsigned(1 downto 0) := (others => '0');
    signal rd_ptr_reg : unsigned(1 downto 0) := (others => '0');
    signal count_reg  : unsigned(2 downto 0) := (others => '0');
    signal full_int   : std_logic := '0';
    signal empty_int  : std_logic := '1'; 
    signal w_en       : std_logic;
    signal r_en       : std_logic;

begin
    full_int  <= '1' when count_reg = 4 else '0';
    empty_int <= '1' when count_reg = 0 else '0';
    
    full  <= full_int;
    empty <= empty_int;

    w_en <= wr and (not full_int); 
    r_en <= rd and (not empty_int); 

    fifo_data_out <= fifo_memory(to_integer(rd_ptr_reg));

    proc_write_ptr: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                wr_ptr_reg <= (others => '0');
            elsif w_en = '1' then
                wr_ptr_reg <= wr_ptr_reg + 1;
            end if;
        end if;
    end process proc_write_ptr;

    proc_read_ptr: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                rd_ptr_reg <= (others => '0');
            elsif r_en = '1' then
                rd_ptr_reg <= rd_ptr_reg + 1;
            end if;
        end if;
    end process proc_read_ptr;

    proc_counter: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                count_reg <= (others => '0');
            else
                if (w_en = '1' and r_en = '0') then
                    count_reg <= count_reg + 1;
                elsif (w_en = '0' and r_en = '1') then
                    count_reg <= count_reg - 1;
                end if;
            end if;
        end if;
    end process proc_counter;

    proc_memory: process(clk)
    begin
        if rising_edge(clk) then
            if w_en = '1' then
                fifo_memory(to_integer(wr_ptr_reg)) <= fifo_data_in;
            end if;
        end if;
    end process proc_memory;

end arch;
