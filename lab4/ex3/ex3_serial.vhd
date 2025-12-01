library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mean_value is 
    port (clk, rst: in std_logic;
          x: in std_logic_vector(15 downto 0);
          y: out std_logic_vector(15 downto 0));
end mean_value;

architecture serial of mean_value is 
    signal serial_in: std_logic_vector(15 downto 0);
    signal accum, serial_out: std_logic_vector(18 downto 0);
    signal cnt: integer range 0 to 8;
begin 
    process(clk, rst)
    begin
        if (rst = '1') then
            serial_in <= (others => '0');
            accum <= (others => '0');
            cnt <= 0;
            serial_out <= (others => '0');
        
        elsif (rising_edge(clk)) then 
        	serial_in <= x;  
            if cnt = 8 then 
            	serial_out <= std_logic_vector(unsigned(accum) + unsigned(serial_in));
            	cnt <= 1;
            	accum <= (others => '0');
            else
                accum <= std_logic_vector(unsigned(accum) + unsigned(serial_in));
                cnt <= cnt + 1;
            end if;
        end if;
        y <= serial_out(18 downto 3);
    end process;
    
end serial;