library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity GF_XA is 
    port(x: in std_logic_vector(7 downto 0);
         y: out std_logic_vector(7 downto 0));
end GF_XA;

architecture structural of GF_XA is 
    component GF_X2 is
        port(x: in std_logic_vector(7 downto 0);
             y: out std_logic_vector(7 downto 0));
    end component;

    component GF_X8 is
        port(x: in std_logic_vector(7 downto 0);
             y: out std_logic_vector(7 downto 0));
    end component;

    signal out_x2 : std_logic_vector(7 downto 0);
    signal out_x8 : std_logic_vector(7 downto 0);
begin 
    U1: GF_X2 port map (x => x, y => out_x2);
    
    U2: GF_X8 port map (x => x, y => out_x8);
    
    y <= out_x8 xor out_x2;
end structural;