library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CLEFIA_M0 is
    Port ( input  : in  std_logic_vector (31 downto 0);
           output : out std_logic_vector (31 downto 0));
end CLEFIA_M0;

architecture structural of CLEFIA_M0 is

    component GF_X2 is 
        port(x: in std_logic_vector(7 downto 0); y: out std_logic_vector(7 downto 0)); 
    end component;
    
    component GF_X4 is 
        port(x: in std_logic_vector(7 downto 0); y: out std_logic_vector(7 downto 0)); 
    end component;
    
    component GF_X6 is 
        port(x: in std_logic_vector(7 downto 0); y: out std_logic_vector(7 downto 0)); 
    end component;

    signal x0, x1, x2, x3 : std_logic_vector(7 downto 0);
    signal x0_2, x0_4, x0_6 : std_logic_vector(7 downto 0);
    signal x1_2, x1_4, x1_6 : std_logic_vector(7 downto 0);
    signal x2_2, x2_4, x2_6 : std_logic_vector(7 downto 0);
    signal x3_2, x3_4, x3_6 : std_logic_vector(7 downto 0);

begin
    x0 <= input(31 downto 24);
    x1 <= input(23 downto 16);
    x2 <= input(15 downto 8);
    x3 <= input(7 downto 0);

    U_x0_2: GF_X2 port map (x => x0, y => x0_2);
    U_x0_4: GF_X4 port map (x => x0, y => x0_4);
    U_x0_6: GF_X6 port map (x => x0, y => x0_6);

    U_x1_2: GF_X2 port map (x => x1, y => x1_2);
    U_x1_4: GF_X4 port map (x => x1, y => x1_4);
    U_x1_6: GF_X6 port map (x => x1, y => x1_6);

    U_x2_2: GF_X2 port map (x => x2, y => x2_2);
    U_x2_4: GF_X4 port map (x => x2, y => x2_4);
    U_x2_6: GF_X6 port map (x => x2, y => x2_6);

    U_x3_2: GF_X2 port map (x => x3, y => x3_2);
    U_x3_4: GF_X4 port map (x => x3, y => x3_4);
    U_x3_6: GF_X6 port map (x => x3, y => x3_6);

    -- M0 = { {01,02,04,06}, {02,01,06,04}, {04,06,01,02}, {06,04,02,01} }
    
    -- Row 0: 01 02 04 06
    output(31 downto 24) <= x0 xor x1_2 xor x2_4 xor x3_6;
    
    -- Row 1: 02 01 06 04
    output(23 downto 16) <= x0_2 xor x1 xor x2_6 xor x3_4;
    
    -- Row 2: 04 06 01 02
    output(15 downto 8)  <= x0_4 xor x1_6 xor x2 xor x3_2;
    
    -- Row 3: 06 04 02 01
    output(7 downto 0)   <= x0_6 xor x1_4 xor x2_2 xor x3;

end structural;