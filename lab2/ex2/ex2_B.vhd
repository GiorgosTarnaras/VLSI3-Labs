library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hex_to_ascii_B is 
	port  (hex : in std_logic_vector(3 downto 0);
		   ascii: out std_logic_vector(7 downto 0));
end hex_to_ascii_B;



architecture myarch of hex_to_ascii_B is 
signal hex_int : integer range 0 to 15;

begin 
    hex_int <= to_integer(unsigned(hex));
    ascii(7 downto 4) <= "0011" when hex_int < 10 else "0100";
    ascii(3 downto 0) <= std_logic_vector(to_unsigned(hex_int, 4)) when hex_int < 10 else
                         std_logic_vector(to_unsigned(hex_int - 9, 4));

end myarch;