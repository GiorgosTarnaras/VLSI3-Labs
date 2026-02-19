library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity GF_X4 is 
    port(x: in std_logic_vector(7 downto 0);
         y: out std_logic_vector(7 downto 0));
end GF_X4;

architecture structural of GF_X4 is 
    component GF_X2 is
        port(x: in std_logic_vector(7 downto 0);
             y: out std_logic_vector(7 downto 0));
    end component;

    signal temp : std_logic_vector(7 downto 0);

begin 
    U1: GF_X2 port map (x => x, y => temp); 
    U2: GF_X2 port map (x => temp, y => y);
end structural;