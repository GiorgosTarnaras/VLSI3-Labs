library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CLEFIA_M1 is
    Port ( input  : in  std_logic_vector (31 downto 0);
           output : out std_logic_vector (31 downto 0));
end CLEFIA_M1;

architecture structural_behav of CLEFIA_M1 is

    component GF_X2 is 
        port(x: in std_logic_vector(7 downto 0); y: out std_logic_vector(7 downto 0)); 
    end component;
    
    component GF_X8 is 
        port(x: in std_logic_vector(7 downto 0); y: out std_logic_vector(7 downto 0)); 
    end component;

    signal x0, x1, x2, x3 : std_logic_vector(7 downto 0);
    signal a0, a1, b0, b1 : std_logic_vector(7 downto 0);
    signal c0, c1, d0, d1 : std_logic_vector(7 downto 0); 
    signal z0, z1, z2, z3 : std_logic_vector(7 downto 0);

begin
    x0 <= input(31 downto 24);
    x1 <= input(23 downto 16);
    x2 <= input(15 downto 8);
    x3 <= input(7 downto 0);

    a0 <= x0 xor x1;
    a1 <= x2 xor x3;
    
    b0 <= x0 xor x2;
    b1 <= x1 xor x3;

    mul_c0: GF_X2 port map (x => a0, y => c0);
    mul_c1: GF_X2 port map (x => a1, y => c1);
    
    mul_d0: GF_X8 port map (x => b0, y => d0);
    mul_d1: GF_X8 port map (x => b1, y => d1);

    z0 <= c1 xor d1 xor x0;
    z1 <= c1 xor d0 xor x1;
    z2 <= c0 xor d1 xor x2;
    z3 <= c0 xor d0 xor x3;

    output <= z0 & z1 & z2 & z3;
    
end structural_behav;