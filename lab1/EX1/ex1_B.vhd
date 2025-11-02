library ieee;
use ieee.std_logic_1164.all;

entity array_slices_2D is 	
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

end array_slices_2D;

architecture arch of array_slices_2D is 

type type_2D is array (1 to 3, 3 downto 0) of std_logic; 
signal my_array: type_2D;

begin 
	my_array(1, 3) <= row1(3);
	my_array(1, 2) <= row1(2);
	my_array(1, 1) <= row1(1);
	my_array(1, 0) <= row1(0);
	my_array(2, 3) <= row2(3);
	my_array(2, 2) <= row2(2);
	my_array(2, 1) <= row2(1);
	my_array(2, 0) <= row2(0);
	my_array(3, 3) <= row3(3);
	my_array(3, 2) <= row3(2);
	my_array(3, 1) <= row3(1);
	my_array(3, 0) <= row3(0);
	
	slice1 <= my_array(ctrl1_R, ctrl1_C);
	slice2 <= my_array(ctrl2, 3) & my_array(ctrl2, 2);
	slice3 <= my_array(ctrl3, 3) & my_array(ctrl3, 2) & my_array(ctrl3, 1) & my_array(ctrl3, 0);
	slice4 <= my_array(1, ctrl4) & my_array(2, ctrl4) & my_array(3, ctrl4);
end arch;