library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity consecutive_ones_counter is
    generic ( n : integer := 8 );  
    port ( x : in std_logic_vector (n-1 downto 0);
           y : out std_logic_vector (integer(ceil(log2(real(n+1))))-1 downto 0);
           ssd : out std_logic_vector (6 downto 0));
end consecutive_ones_counter;

architecture arch3 of consecutive_ones_counter is
    constant m : integer := integer(ceil(log2(real(n+1))));
    
    signal count : integer range 0 to n;
    signal y_temp : std_logic_vector(m-1 downto 0);
    

    function count_to_ssd(cnt : integer) return std_logic_vector is
        variable result : std_logic_vector(6 downto 0);
    library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity consecutive_ones_counter is
    generic ( n : integer := 8 );  
    port ( x : in std_logic_vector (n-1 downto 0);
           y : out std_logic_vector (integer(ceil(log2(real(n+1))))-1 downto 0);
           ssd : out std_logic_vector (6 downto 0));
end consecutive_ones_counter;

architecture arch3 of consecutive_ones_counter is
    constant m : integer := integer(ceil(log2(real(n+1))));
    
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
    

    y <= std_logic_vector(to_unsigned(count, m));
    

    ssd <= "0000001" when count = 0 else  -- 0
           "1001111" when count = 1 else  -- 1
           "0010010" when count = 2 else  -- 2
           "0000110" when count = 3 else  -- 3
           "1001100" when count = 4 else  -- 4
           "0100100" when count = 5 else  -- 5
           "0100000" when count = 6 else  -- 6
           "0001111" when count = 7 else  -- 7
           "0000000" when count = 8 else  -- 8
           "0000100" when count = 9 else  -- 9
           "1111111";  


end arch3;
