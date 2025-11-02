library ieee;
use ieee.std_logic_1164.all;

entity array_slices_x1D is 	
	port(
		row1: in  std_logic_vector(3 downto 0);
		row2: in  std_logic_vector(3 downto 0);
		row3: in  std_logic_vector(3 downto 0);
		ctrl1_R: in integer range 1 to 3;
		ctrl1_C: in integer range 0 to 3;
		ctrl2: in integer range 1 to 3;
		ctrl3: in integer range 1 to 3;
		ctrl4: in integer range 0 to 3;
		slice1: out std_logic;
		slice2: out std_logic_vector(1 downto 0);
		slice3: out std_logic_vector(3 downto 0);
		slice4: out std_logic_vector(2 downto 0)
		);

end array_slices_x1D;

architecture arch of array_slices_x1D is 

type type_1Dx1D is array (1 to 3) of std_logic_vector(3 downto 0); 
signal my_array: type_1Dx1D;
begin 

	my_array <= (row1, row2, row3);
	slice1 <= my_array(ctrl1_R)(ctrl1_C);
	slice2 <= my_array(ctrl2)(3 downto 2);
	slice3 <= my_array(ctrl3);
	slice4 <= my_array(1)(ctrl4) & my_array(2)(ctrl4) & my_array(3)(ctrl4);
end arch;