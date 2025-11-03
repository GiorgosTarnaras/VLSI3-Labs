library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity consecutive_ones_counter is
    generic ( n : integer := 8 );  
    port ( x : in std_logic_vector (n-1 downto 0);
           y : out std_logic_vector (3 downto 0);
           ssd : out std_logic_vector (6 downto 0));
end consecutive_ones_counter;

architecture arch3 of consecutive_ones_counter is

    constant m : integer := 5 when n > 16 else
                           4 when n > 8 else
                           3 when n > 4 else
                           2 when n > 2 else
                           1;
    
    signal count : integer range 0 to n;
    signal y_temp : std_logic_vector(m-1 downto 0);
    

    
begin
    
	count <= 8 when x(n-1 downto 0) = (n-1 downto 0 => '1') else
             7 when x(n-1 downto 1) = (n-1 downto 1 => '1') else
             6 when x(n-1 downto 2) = (n-1 downto 2 => '1') else
             5 when x(n-1 downto 3) = (n-1 downto 3 => '1') else
             4 when x(n-1 downto 4) = (n-1 downto 4 => '1') else
             3 when x(n-1 downto 5) = (n-1 downto 5 => '1') else
             2 when x(n-1 downto 6) = (n-1 downto 6 => '1') else
             1 when x(n-1) = '1' else
             0;

    
 
    y_temp <= std_logic_vector(to_unsigned(count, m));
    
  
    y <= std_logic_vector(resize(unsigned(y_temp), 4));
    
    
    ssd <= "0000001" when count = 0 else  
           "1001111" when count = 1 else  
           "0010010" when count = 2 else  
           "0000110" when count = 3 else  
           "1001100" when count = 4 else 
           "0100100" when count = 5 else  
           "0100000" when count = 6 else  
           "0001111" when count = 7 else  
           "0000000" when count = 8 else  
           "0000100" when count = 9 else  
           "0001000" when count = 10 else  
           "1100000" when count = 11 else  
           "0110001" when count = 12 else  
           "1000010" when count = 13 else  
           "0110000" when count = 14 else  
           "0111000" when count = 15 else  
           "1111111";  
           
end arch3;
