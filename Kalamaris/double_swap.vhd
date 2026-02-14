library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CLEFIA_DOUBLE_SWAP is
    Port ( input  : in  std_logic_vector (127 downto 0);
           output : out std_logic_vector (127 downto 0));
end CLEFIA_DOUBLE_SWAP;

architecture behavioral of CLEFIA_DOUBLE_SWAP is
begin    
    output <= input(120 downto 64) & -- 57 bits
              input(6 downto 0)    & -- 7 bits
              input(127 downto 121) & -- 7 bits
              input(63 downto 7);     -- 57 bits

end behavioral;