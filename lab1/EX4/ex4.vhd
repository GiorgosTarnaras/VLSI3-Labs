library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity cons_ones_counter_display is
	generic (N: integer := 8); -- log2 of N
	port(x: in std_logic_vector(N-1 downto 0);
		 y: out std_logic_vector(integer(ceil(log(real(N+1)) / log(2.0))) - 1 downto 0);
		 ssd: out std_logic_vector(6 downto 0));
end cons_ones_counter_display; 


architecture arch of cons_ones_counter_display is

type integer_vector is array (0 to N-1) of integer range 0 to N; 
signal cons_ones, max_cons_ones : integer_vector;
constant M : integer := integer(ceil(log(real(N+1)) / log(2.0)));

begin 
	cons_ones(0) <= 1 when x(0) = '1' else 0;
    max_cons_ones(0) <= cons_ones(0);
	for_gen:
	for i in 1 to N-1 generate
		cons_ones(i) <= (cons_ones(i-1) + 1) when (x(i) = '1' and x(i-1) = '1') else
						(1) when (x(i) = '1') else
						(0);
		max_cons_ones(i) <= (cons_ones(i)) when max_cons_ones(i-1) < cons_ones(i) else
							max_cons_ones(i-1);
	end generate;
	
	y <= std_logic_vector(to_unsigned(max_cons_ones(N-1), M));
	ssd  <= "0000001" when max_cons_ones(N-1) = 0 else  
           "1001111" when max_cons_ones(N-1) = 1 else  
           "0010010" when max_cons_ones(N-1) = 2 else  
           "0000110" when max_cons_ones(N-1) = 3 else  
           "1001100" when max_cons_ones(N-1) = 4 else 
           "0100100" when max_cons_ones(N-1) = 5 else  
           "0100000" when max_cons_ones(N-1) = 6 else  
           "0001111" when max_cons_ones(N-1) = 7 else  
           "0000000" when max_cons_ones(N-1) = 8 else  
           "0000100" when max_cons_ones(N-1) = 9 else  
           "0001000" when max_cons_ones(N-1) = 10 else  
           "1100000" when max_cons_ones(N-1) = 11 else  
           "0110001" when max_cons_ones(N-1) = 12 else  
           "1000010" when max_cons_ones(N-1) = 13 else  
           "0110000" when max_cons_ones(N-1) = 14 else  
           "0111000" when max_cons_ones(N-1) = 15 else  
           "1111111";



      

end arch;