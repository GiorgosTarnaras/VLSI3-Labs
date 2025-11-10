library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity parity_checker_rearrange is 
	generic ( N : integer := 8 ); 
	port (x : in std_logic_vector (N-1 downto 0);
		   y: out std_logic_vector(N-1 downto 0);
		   parity_bit: out std_logic);
end parity_checker_rearrange;



architecture myarch of parity_checker_rearrange is 
type integer_vector is array (0 to N-1) of integer range 0 to N;
signal sum : integer_vector;

begin 

	sum(0) <= 0 when (x(0) = '0') else 1;
	gen_sum:
	for i in 1 to N-1 generate
		sum(i) <= sum(i-1) when (x(i) = '0') else sum(i-1) + 1; 	
	end generate;

	parity_bit <= '1' when (sum(N-1) mod 2) = 0 else '0'; 
	gen_y:
	for i in 0 to N-1 generate
		y(i) <= '1' when i < sum(N-1) else '0';
	end generate;

end myarch;