library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hex_to_ascii is 
	port  (hex : in std_logic_vector(3 downto 0);
		   ascii: out std_logic_vector(7 downto 0));
end hex_to_ascii;



architecture myarch of hex_to_ascii is 

begin 
    with hex select
    ascii <= x"30" when "0000",  -- '0'
             x"31" when "0001",  -- '1'
             x"32" when "0010",  -- '2'
             x"33" when "0011",  -- '3'
             x"34" when "0100",  -- '4'
             x"35" when "0101",  -- '5'
             x"36" when "0110",  -- '6'
             x"37" when "0111",  -- '7'
             x"38" when "1000",  -- '8'
             x"39" when "1001",  -- '9'
             x"41" when "1010",  -- 'A'
             x"42" when "1011",  -- 'B'
             x"43" when "1100",  -- 'C'
             x"44" when "1101",  -- 'D'
             x"45" when "1110",  -- 'E'
             x"46" when "1111",  -- 'F'
             (others => '0') when others;  -- default

end myarch;