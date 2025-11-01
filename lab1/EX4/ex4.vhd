library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cons_ones_counter_display is
	generic (N: integer := 8;
			 M: integer := 3); -- log2 of N
	port(x: in std_logic_vector(N-1 downto 0);
		 y: out std_logic_vector(M-1 downto 0);
		 ssd: out std_logic_vector(6 downto 0));
end cons_ones_counter_display; 


architecture arch of cons_ones_counter_display is

function int_to_lcd (input: integer) return std_logic_vector is 
begin 
case input is 
	when 0  => return "0000001"; -- 0
    when 1  => return "1001111"; -- 1
    when 2  => return "0010010"; -- 2
    when 3  => return "0000110"; -- 3
    when 4  => return "1001100"; -- 4
    when 5  => return "0100100"; -- 5
    when 6  => return "0100000"; -- 6
    when 7  => return "0001111"; -- 7
    when 8  => return "0000000"; -- 8
    when 9  => return "0000100"; -- 9
    when 10 => return "0001000"; -- A
    when 11 => return "1100000"; -- b
    when 12 => return "0110001"; -- C
    when 13 => return "1000010"; -- d
    when 14 => return "0110000"; -- E
    when 15 => return "0111000"; -- F
    when others => return "1111111"; -- all off
end case;
end function;


type integer_vector is array (0 to N-1) of integer range 0 to N; 
signal cons_ones, max_cons_ones : integer_vector;
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
	ssd <= int_to_lcd(max_cons_ones(N-1));

end arch;