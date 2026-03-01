library ieee;
use ieee.std_logic_1164.all;

entity CLEFIA_8_DOUBLE_SWAP is
    Port ( input  : in  std_logic_vector (127 downto 0);
           output : out std_logic_vector (127 downto 0));
end CLEFIA_8_DOUBLE_SWAP;

architecture behavioral of CLEFIA_8_DOUBLE_SWAP is
begin    
    output <= input(71 downto 64) & 
              input(6 downto 0)    & 
              input(13 downto 7) &
              input(20 downto 14)&  
			  input(27 downto 21)&
			  input(34 downto 28)&
			  input(41 downto 35)& 	
			  input(48 downto 42)& 		
			  input(55 downto 49)& 	
			  input(78 downto 72)& 
			  input(85 downto 79)&
			  input(92 downto 86)& 
			  input(99 downto 93)& 
			  input(106 downto 100)&
			  input(113 downto 107)& 
			  input(120 downto 114)& 
			  input(127 downto 121)&
			  input(63 downto 56); 					  

end behavioral;
