library ieee;
use ieee.std_logic_1164.all;

entity CLEFIA_DOUBLE_SWAP is
    Port ( input  : in  std_logic_vector (127 downto 0);
           output : out std_logic_vector (127 downto 0));
end CLEFIA_DOUBLE_SWAP;

architecture behavioral of CLEFIA_DOUBLE_SWAP is
begin    
    output <= input(120 downto 64) & 
              input(6 downto 0)    & 
              input(127 downto 121) & 
              input(63 downto 7);   

end behavioral;