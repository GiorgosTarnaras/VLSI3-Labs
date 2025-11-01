library ieee;
use ieee.std_logic_1164.all;
use ieee.nmeric_std.all;

entity priority_encoder is
    port ( r : in std_logic_vector (7 downto 0);
           c : in std_logic_vector (2 downto 0);
           code : out std_logic_vector (2 downto 0);
           active : out std_logic);
end priority_encoder;

architecture arch1 of priority_encoder is
    signal r_rotated : std_logic_vector(7 downto 0);
    signal code_temp : std_logic_vector(2 downto 0);
begin
    active <= '1' when (r /= "00000000") else '0';
    
    r_rotated <= r(7 downto 0) when c = "111" else
                 r(6 downto 0) & r(7) when c = "110" else
                 r(5 downto 0) & r(7 downto 6) when c = "101" else
                 r(4 downto 0) & r(7 downto 5) when c = "100" else
                 r(3 downto 0) & r(7 downto 4) when c = "011" else
                 r(2 downto 0) & r(7 downto 5) when c = "010" else
                 r(1 downto 0) & r(7 downto 6) when c = "001" else
                 r(0) & r(7 downto 1); 
    
    code_temp <= "111" when r_rotated(7) = '1' else
                 "110" when r_rotated(6) = '1' else
                 "101" when r_rotated(5) = '1' else
                 "100" when r_rotated(4) = '1' else
                 "011" when r_rotated(3) = '1' else
                 "010" when r_rotated(2) = '1' else
                 "001" when r_rotated(1) = '1' else
                 "000" when r_rotated(0) = '1' else
                 "000";  
				 
    code <= std_logic_vector(unsigned(c) - unsigned(code_temp)) when unsigned(c) >= unsigned(code_temp) else
        std_logic_vector(to_unsigned(7, 3) + unsigned(c) - unsigned(code_temp));

end arch1;
