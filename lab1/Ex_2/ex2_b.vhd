library ieee;
use ieee.std_logic_1164.all;

entity exercise_2 is
    port(
        r     : in  std_logic_vector(7 downto 0); 
        c     : in  std_logic_vector(2 downto 0); 
        code  : out std_logic_vector(2 downto 0); 
        active: out std_logic                 
    );
end entity exercise_2;

architecture arch2 of exercise_2 is
begin
    active <= '0' when r = "00000000" else '1';
    
    code <= "000" when c = "000" and r(0) = '1' else
            "111" when c = "000" and r(7) = '1' else
            "110" when c = "000" and r(6) = '1' else
            "101" when c = "000" and r(5) = '1' else
            "100" when c = "000" and r(4) = '1' else
            "011" when c = "000" and r(3) = '1' else
            "010" when c = "000" and r(2) = '1' else
            "001" when c = "000" and r(1) = '1' else
            
            "001" when c = "001" and r(1) = '1' else
            "000" when c = "001" and r(0) = '1' else
            "111" when c = "001" and r(7) = '1' else
            "110" when c = "001" and r(6) = '1' else
            "101" when c = "001" and r(5) = '1' else
            "100" when c = "001" and r(4) = '1' else
            "011" when c = "001" and r(3) = '1' else
            "010" when c = "001" and r(2) = '1' else
            
            "010" when c = "010" and r(2) = '1' else
            "001" when c = "010" and r(1) = '1' else
            "000" when c = "010" and r(0) = '1' else
            "111" when c = "010" and r(7) = '1' else
            "110" when c = "010" and r(6) = '1' else
            "101" when c = "010" and r(5) = '1' else
            "100" when c = "010" and r(4) = '1' else
            "011" when c = "010" and r(3) = '1' else
            
            "011" when c = "011" and r(3) = '1' else
            "010" when c = "011" and r(2) = '1' else
            "001" when c = "011" and r(1) = '1' else
            "000" when c = "011" and r(0) = '1' else
            "111" when c = "011" and r(7) = '1' else
            "110" when c = "011" and r(6) = '1' else
            "101" when c = "011" and r(5) = '1' else
            "100" when c = "011" and r(4) = '1' else
            
            "100" when c = "100" and r(4) = '1' else
            "011" when c = "100" and r(3) = '1' else
            "010" when c = "100" and r(2) = '1' else
            "001" when c = "100" and r(1) = '1' else
            "000" when c = "100" and r(0) = '1' else
            "111" when c = "100" and r(7) = '1' else
            "110" when c = "100" and r(6) = '1' else
            "101" when c = "100" and r(5) = '1' else
            
            "101" when c = "101" and r(5) = '1' else
            "100" when c = "101" and r(4) = '1' else
            "011" when c = "101" and r(3) = '1' else
            "010" when c = "101" and r(2) = '1' else
            "001" when c = "101" and r(1) = '1' else
            "000" when c = "101" and r(0) = '1' else
            "111" when c = "101" and r(7) = '1' else
            "110" when c = "101" and r(6) = '1' else
            
            "110" when c = "110" and r(6) = '1' else
            "101" when c = "110" and r(5) = '1' else
            "100" when c = "110" and r(4) = '1' else
            "011" when c = "110" and r(3) = '1' else
            "010" when c = "110" and r(2) = '1' else
            "001" when c = "110" and r(1) = '1' else
            "000" when c = "110" and r(0) = '1' else
            "111" when c = "110" and r(7) = '1' else
            
            "111" when c = "111" and r(7) = '1' else
            "110" when c = "111" and r(6) = '1' else
            "101" when c = "111" and r(5) = '1' else
            "100" when c = "111" and r(4) = '1' else
            "011" when c = "111" and r(3) = '1' else
            "010" when c = "111" and r(2) = '1' else
            "001" when c = "111" and r(1) = '1' else
            "000" when c = "111" and r(0) = '1' else
            
            "000";
            
end architecture arch2;