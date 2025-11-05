library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity consecutive_ones_counter is
    generic ( n : integer := 8 );  
    port ( x : in std_logic_vector (n-1 downto 0);
           y : out std_logic_vector (integer(ceil(log(real(n)) / log(2.0))) downto 0);
           ssd : out std_logic_vector (6 downto 0));
end consecutive_ones_counter;

architecture arch3 of consecutive_ones_counter is

    constant m : integer := integer(ceil(log(real(n)) / log(2.0)));
    
    signal count : integer range 0 to n;
    signal y_temp : std_logic_vector(m-1 downto 0);
    
 
    type match_array is array (0 to n) of std_logic;
    signal matches : match_array;
    
begin
    

    matches(0) <= '1';
    

    GEN_MATCHES: for i in 1 to n generate
        matches(i) <= '1' when x(n-1 downto n-i) = (n-1 downto n-i => '1') else '0';
    end generate GEN_MATCHES;

    count <= n   when matches(n)   = '1' else
             n-1 when (n > 1 and matches(n-1) = '1') else
             n-2 when (n > 2 and matches(n-2) = '1') else
             n-3 when (n > 3 and matches(n-3) = '1') else
             n-4 when (n > 4 and matches(n-4) = '1') else
             n-5 when (n > 5 and matches(n-5) = '1') else
             n-6 when (n > 6 and matches(n-6) = '1') else
             n-7 when (n > 7 and matches(n-7) = '1') else
             1 when matches(1) = '1' else
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