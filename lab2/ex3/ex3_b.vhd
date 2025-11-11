library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity parity_checker_rearrange_2 is 
	generic ( N : integer := 8 ); 
	port (x : in std_logic_vector (N-1 downto 0);
		   y: out std_logic_vector(N-1 downto 0);
		   parity_bit: out std_logic);
end parity_checker_rearrange_2;

architecture myarch of parity_checker_rearrange_2 is 
type type_1Dx1D is array (0 to N) of std_logic_vector(N-1 downto 0); 
signal temp: type_1Dx1D;
signal par_temp: std_logic_vector(N-1 downto 0);
begin 
	temp(0) <= (others => '1');
	par_temp(0) <= x(0);
	gen_array:
	for i in 1 to N generate
		temp(i) <= '0' & temp(i-1)(N-1 downto 1) when (x(i-1) = '0') else temp(i-1);
	end generate;
	
	gen_par:
	for i in 1 to N-1 generate
		par_temp(i) <= x(i) xor par_temp(i-1);
	end generate;
	
	y <= temp(N);

	parity_bit <= not par_temp(N-1);

end myarch;