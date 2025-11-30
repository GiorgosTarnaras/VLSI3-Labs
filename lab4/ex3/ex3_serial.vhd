library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mean_value is 
	port (clk, rst: in std_logic;
		  x: in std_logic_vector(15 downto 0);
		  y: out std_logic_vector(15 downto 0));
end mean_value;


architecture serial of mean_value is 
signal accum, serial_in: std_logic_vector(15 downto 0);
signal counter : integer range 0 to 8 := 0;
begin 
	process(clk, rst)
    begin
		if (rst = '1') then 
			accum <= (others => '0');
			serial_in <= (others => '0');
			y <= (others => '0');
			counter <= 0;
		elsif (rising_edge(clk)) then	
			
			if counter = 8 then 
				y <= accum;
				counter <= 0;
			else
				counter <= counter + 1;
			end if;

			serial_in <= (15 => '0', 14 => '0', 13 => '0', others => x(12 downto 0));
			accum <= std_logic_vector(unsigned(accum) + unsigned(serial_in));

		end if;

	end process;
	
	
end serial;