library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hex_to_ascii_C is 
	port  (hex : in std_logic_vector(3 downto 0);
		   ascii: out std_logic_vector(7 downto 0));
end hex_to_ascii_C;



architecture myarch of hex_to_ascii_C is 
signal hex_int : integer range 0 to 15;

begin 
    hex_int <= to_integer(unsigned(hex));
    ascii <= std_logic_vector(to_unsigned(48+hex_int, 8) when hex_int < 10 else
                         to_unsigned(55+hex_int, 8));

end myarch;