library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CLEFIA_INV_DOUBLE_SWAP is
    Port ( input  : in  std_logic_vector (127 downto 0);
           output : out std_logic_vector (127 downto 0));
end CLEFIA_INV_DOUBLE_SWAP;

architecture behavioral of CLEFIA_INV_DOUBLE_SWAP is
begin    
    output <= input(63 downto 57) & 
              input(127 downto 71)    & 
              input(56 downto 0) &
              input(70 downto 64);			  

end behavioral;