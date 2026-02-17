library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CLEFIA_M1 is
    Port ( input  : in  std_logic_vector (31 downto 0);
           output : out std_logic_vector (31 downto 0));
end CLEFIA_M1;

architecture structural of CLEFIA_M1 is

    component GF_X2 is 
        port(x: in std_logic_vector(7 downto 0); y: out std_logic_vector(7 downto 0)); 
    end component;
    
    component GF_X8 is 
        port(x: in std_logic_vector(7 downto 0); y: out std_logic_vector(7 downto 0)); 
    end component;
    
    component GF_XA is 
        port(x: in std_logic_vector(7 downto 0); y: out std_logic_vector(7 downto 0)); 
    end component;

    signal x0, x1, x2, x3 : std_logic_vector(7 downto 0);

    signal x0_2, x0_8, x0_A : std_logic_vector(7 downto 0);
    signal x1_2, x1_8, x1_A : std_logic_vector(7 downto 0);
    signal x2_2, x2_8, x2_A : std_logic_vector(7 downto 0);
    signal x3_2, x3_8, x3_A : std_logic_vector(7 downto 0);

begin
    x0 <= input(31 downto 24);
    x1 <= input(23 downto 16);
    x2 <= input(15 downto 8);
    x3 <= input(7 downto 0);

    U_x0_2: GF_X2 port map (x => x0, y => x0_2);
    U_x0_8: GF_X8 port map (x => x0, y => x0_8);
    U_x0_A: GF_XA port map (x => x0, y => x0_A);

    U_x1_2: GF_X2 port map (x => x1, y => x1_2);
    U_x1_8: GF_X8 port map (x => x1, y => x1_8);
    U_x1_A: GF_XA port map (x => x1, y => x1_A);

    U_x2_2: GF_X2 port map (x => x2, y => x2_2);
    U_x2_8: GF_X8 port map (x => x2, y => x2_8);
    U_x2_A: GF_XA port map (x => x2, y => x2_A);

    U_x3_2: GF_X2 port map (x => x3, y => x3_2);
    U_x3_8: GF_X8 port map (x => x3, y => x3_8);
    U_x3_A: GF_XA port map (x => x3, y => x3_A);

    
    -- Row 0: 01 08 02 0A
    output(31 downto 24) <= x0 xor x1_8 xor x2_2 xor x3_A;
    
    -- Row 1: 08 01 0A 02
    output(23 downto 16) <= x0_8 xor x1 xor x2_A xor x3_2;
    
    -- Row 2: 02 0A 01 08
    output(15 downto 8)  <= x0_2 xor x1_A xor x2 xor x3_8;
    
    -- Row 3: 0A 02 08 01
    output(7 downto 0)   <= x0_A xor x1_2 xor x2_8 xor x3;

end structural;