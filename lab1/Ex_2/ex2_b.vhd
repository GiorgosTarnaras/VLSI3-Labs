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

    code <=

        ("000" when r(0) = '1' else
         "111" when r(7) = '1' else
         "110" when r(6) = '1' else
         "101" when r(5) = '1' else
         "100" when r(4) = '1' else
         "011" when r(3) = '1' else
         "010" when r(2) = '1' else
         "001" when r(1) = '1' else "000") when c = "000" else

        ("001" when r(1) = '1' else
         "000" when r(0) = '1' else
         "111" when r(7) = '1' else
         "110" when r(6) = '1' else
         "101" when r(5) = '1' else
         "100" when r(4) = '1' else
         "011" when r(3) = '1' else
         "010" when r(2) = '1' else "000") when c = "001" else

        ("010" when r(2) = '1' else
         "001" when r(1) = '1' else
         "000" when r(0) = '1' else
         "111" when r(7) = '1' else
         "110" when r(6) = '1' else
         "101" when r(5) = '1' else
         "100" when r(4) = '1' else
         "011" when r(3) = '1' else "000") when c = "010" else

        ("011" when r(3) = '1' else
         "010" when r(2) = '1' else
         "001" when r(1) = '1' else
         "000" when r(0) = '1' else
         "111" when r(7) = '1' else
         "110" when r(6) = '1' else
         "101" when r(5) = '1' else
         "100" when r(4) = '1' else "000") when c = "011" else

        ("100" when r(4) = '1' else
         "011" when r(3) = '1' else
         "010" when r(2) = '1' else
         "001" when r(1) = '1' else
         "000" when r(0) = '1' else
         "111" when r(7) = '1' else
         "110" when r(6) = '1' else
         "101" when r(5) = '1' else "000") when c = "100" else

        ("101" when r(5) = '1' else
         "100" when r(4) = '1' else
         "011" when r(3) = '1' else
         "010" when r(2) = '1' else
         "001" when r(1) = '1' else
         "000" when r(0) = '1' else
         "111" when r(7) = '1' else
         "110" when r(6) = '1' else "000") when c = "101" else

        ("110" when r(6) = '1' else
         "101" when r(5) = '1' else
         "100" when r(4) = '1' else
         "011" when r(3) = '1' else
         "010" when r(2) = '1' else
         "001" when r(1) = '1' else
         "000" when r(0) = '1' else
         "111" when r(7) = '1' else "000") when c = "110" else

        ("111" when r(7) = '1' else
         "110" when r(6) = '1' else
         "101" when r(5) = '1' else
         "100" when r(4) = '1' else
         "011" when r(3) = '1' else
         "010" when r(2) = '1' else
         "001" when r(1) = '1' else
         "000" when r(0) = '1' else "000");

end architecture arch2;
