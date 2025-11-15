library ieee;
use ieee.std_logic_1164.all;


entity barrel_shifter is
    Port ( a   : in  std_logic_vector(7 downto 0);
           lar : in  std_logic_vector(1 downto 0);  
           amt : in  std_logic_vector(2 downto 0);  
           y   : out std_logic_vector(7 downto 0));
end barrel_shifter;

architecture arch1 of barrel_shifter is
 
    signal shifted : std_logic_vector(7 downto 0);
begin
 
    shifted <= a when amt = "000" else
 
               ("0") & a(7 downto 1)   when amt = "001" and lar = "00" else
               a(7) & a(7 downto 1)  when amt = "001" and lar = "01" else
               a(0) & a(7 downto 1)  when amt = "001" else  
 
               ("00") & a(7 downto 2)  when amt = "010" and lar = "00" else
               a(7) & "0" & a(7 downto 2) when amt = "010" and lar = "01" else
               a(1 downto 0) & a(7 downto 2) when amt = "010" else  
 
               ("000") & a(7 downto 3) when amt = "011" and lar = "00" else
               a(7) & "00" & a(7 downto 3) when amt = "011" and lar = "01" else
               a(2 downto 0) & a(7 downto 3) when amt = "011" else  
 
               ("0000") & a(7 downto 4) when amt = "100" and lar = "00" else
               a(7) & "000" & a(7 downto 4) when amt = "100" and lar = "01" else
               a(3 downto 0) & a(7 downto 4) when amt = "100" else  
 
               ("00000") & a(7 downto 5) when amt = "101" and lar = "00" else
               a(7) & "0000" & a(7 downto 5) when amt = "101" and lar = "01" else
               a(4 downto 0) & a(7 downto 5) when amt = "101" else  
 
               ("000000") & a(7 downto 6) when amt = "110" and lar = "00" else
               a(7) & "00000" & a(7 downto 6) when amt = "110" and lar = "01" else
               a(5 downto 0) & a(7 downto 6) when amt = "110" else  
 
               ("0000000") & a(7) when amt = "111" and lar = "00" else  
               a(7) & "000000" & a(7) when amt = "111" and lar = "01" else
               a(6 downto 0) & a(7); 
 
    y <= shifted;
 
end arch1;