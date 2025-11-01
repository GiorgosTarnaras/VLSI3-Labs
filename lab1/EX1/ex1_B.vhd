library ieee;
use ieee.std_logic_1164.all;

entity array_slices_2D is 	
	port(
		row1: in  std_logic_vector(3 downto 0);
		row2: in  std_logic_vector(3 downto 0);
		row3: in  std_logic_vector(3 downto 0);
		slice1: out std_logic;
		slice2: out std_logic_vector(1 downto 0);
		slice3: out std_logic_vector(3 downto 0);
		slice4: out std_logic_vector(2 downto 0)
		);

end array_slices_2D;

architecture arch of array_slices_2D is 

type type_2D is array (natural range <>, natural range <>) of std_logic; 
signal my_array: type_2D(0 to 2, 3 downto 0);
begin 
	my_array <= (row1, row2, row3);
	slice1 <= my_array(0, 3);
	slice2 <= my_array(1, 3) & my_array(1, 2);
	slice3 <= my_array(2, 3) & my_array(2, 2) & my_array(2, 1) & my_array(2, 0);
	slice4 <= my_array(0, 0) & my_array(1, 0) & my_array(2, 0);
end arch;