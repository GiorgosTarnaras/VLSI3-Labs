library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity GF_X2 is 
	port(x: in std_logic_vector(7 downto 0);
		 y: out std_logic_vector(7 downto 0));
end GF_X2;

architecture behavioral of GF_X2 is 
signal msb: std_logic;
begin 
	msb <= x(7);
	with msb select
		y <= x(6 downto 0) & '0' when '0',
			(x(6 downto 0) & '0') xor (x"1d") when others;
end behavioral;