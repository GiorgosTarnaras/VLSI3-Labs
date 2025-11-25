library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity universal_binary_counter is
    Port ( 
        clk        : in  std_logic;
        reset      : in  std_logic;  
        synch_clr  : in  std_logic; 
        load       : in  std_logic;  
        en         : in  std_logic;  
        up         : in  std_logic;  
        d          : in  std_logic_vector(3 downto 0);  
        Q          : out std_logic_vector(3 downto 0); 
        max        : out std_logic; 
        min        : out std_logic  
    );
end universal_binary_counter;

architecture arch of universal_binary_counter is
    signal count_reg : unsigned(3 downto 0) := (others => '0');
    constant MAX_VAL : unsigned(3 downto 0) := "1111";
    constant MIN_VAL : unsigned(3 downto 0) := "0000";
begin

  
    counter_proc: process(clk, reset)
    begin
        if reset = '1' then
            count_reg <= (others => '0');
        elsif rising_edge(clk) then
            if synch_clr = '1' then
                count_reg <= (others => '0');
            elsif load = '1' then
                count_reg <= unsigned(d);
            elsif en = '1' then
                if up = '1' then
                    count_reg <= count_reg + 1;
                else
                    count_reg <= count_reg - 1;
                end if;
            end if;

        end if;
    end process;


    Q <= std_logic_vector(count_reg);
    
    max <= '1' when count_reg = MAX_VAL else '0';
    min <= '1' when count_reg = MIN_VAL else '0';

end arch;
