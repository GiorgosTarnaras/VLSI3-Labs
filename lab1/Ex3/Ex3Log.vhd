library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity consecutive_ones_counter is
    generic ( n : integer := 8 );  
    port ( x : in std_logic_vector (n-1 downto 0);
           y : out std_logic_vector (integer(ceil(log(real(n+1)) / log(2.0))) -1 downto 0);
           ssd : out std_logic_vector (6 downto 0));
end consecutive_ones_counter;

architecture arch3 of consecutive_ones_counter is
	type integer_vector is array (0 to n-1) of integer range 0 to n;
	constant m : integer := integer(ceil(log(real(n+1)) / log(2.0)));
    signal count : integer_vector ;
	signal en : std_logic_vector (n-1 downto 0);

    
begin
    en(n-1) <= x(n-1);
	count(n-1) <= 1 when(x(n-1) = '1' ) else 0;
    for_gen:
	for i in n-2 downto 0 generate
		en(i) <= '1' when (en(i+1) = '1' and x(i) = '1') else '0';
		count(i) <= count(i+1) + 1 when (en(i) = '1') else count(i+1);
	end generate;

    y <= std_logic_vector(to_unsigned(count(0), m));
    
    
        ssd <= "0000001" when count(0) = 0 else   
               "1001111" when count(0) = 1 else   
               "0010010" when count(0) = 2 else  
               "0000110" when count(0) = 3 else   
               "1001100" when count(0) = 4 else  
               "0100100" when count(0) = 5 else 
               "0100000" when count(0) = 6 else   
               "0001111" when count(0) = 7 else   
               "0000000" when count(0) = 8 else  
               "0000100" when count(0) = 9 else 
               "0001000" when count(0) = 10 else 
               "1100000" when count(0) = 11 else 
               "0110001" when count(0) = 12 else
               "1000010" when count(0) = 13 else
               "0110000" when count(0) = 14 else 
               "0111000" when count(0) = 15 else
               "1111111" ;  
           
end arch3;
