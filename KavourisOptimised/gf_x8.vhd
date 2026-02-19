library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity GF_X8 is 
    port(x: in std_logic_vector(7 downto 0);
         y: out std_logic_vector(7 downto 0));
end GF_X8;

architecture structural of GF_X8 is 
    component GF_X2 is
        port(x: in std_logic_vector(7 downto 0);
             y: out std_logic_vector(7 downto 0));
    end component;

    component GF_X4 is
        port(x: in std_logic_vector(7 downto 0);
             y: out std_logic_vector(7 downto 0));
    end component;

    signal temp_x4 : std_logic_vector(7 downto 0);
begin 
    U1: GF_X4 port map (x => x, y => temp_x4);
    U2: GF_X2 port map (x => temp_x4, y => y);
end structural;