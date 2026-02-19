library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CLEFIA_S0 is
    Port ( x : in  std_logic_vector (7 downto 0);
           y : out std_logic_vector (7 downto 0));
end CLEFIA_S0;

architecture behavioral of CLEFIA_S0_OPT is
    signal x0, x1 : std_logic_vector(3 downto 0);
    signal t0, t1 : std_logic_vector(3 downto 0); -- After SS0, SS1
    signal m0, m1 : std_logic_vector(3 downto 0); -- After x2 multiplication
    signal z0, z1 : std_logic_vector(3 downto 0); -- After XOR
    signal y0, y1 : std_logic_vector(3 downto 0); -- Final nibbles
    
    component GF_MUL2_4BIT 
    Port ( x : in  std_logic_vector (3 downto 0);
           y : out std_logic_vector (3 downto 0));
    end component;
    

    type ss_array is array (0 to 15) of std_logic_vector(3 downto 0);
    constant SS0_ROM : ss_array := (x"e", x"6", x"c", x"a", x"8", x"7", x"2", x"f", x"b", x"1", x"4", x"0", x"5", x"9", x"d", x"3");
    constant SS1_ROM : ss_array := (x"6", x"4", x"0", x"d", x"2", x"b", x"a", x"3", x"9", x"c", x"e", x"f", x"8", x"7", x"5", x"1");
    constant SS2_ROM : ss_array := (x"b", x"8", x"5", x"e", x"a", x"6", x"4", x"c", x"f", x"7", x"2", x"3", x"1", x"0", x"d", x"9");
    constant SS3_ROM : ss_array := (x"a", x"2", x"6", x"d", x"3", x"4", x"5", x"e", x"0", x"7", x"8", x"9", x"b", x"f", x"c", x"1");

begin
-- 1. Split inputs
    x0 <= x(7 downto 4);
    x1 <= x(3 downto 0);

    -- 2. First layer of SS boxes
    t0 <= SS0_ROM(to_integer(unsigned(x0)));
    t1 <= SS1_ROM(to_integer(unsigned(x1)));

    -- 3. Multiplication instances (matching your logic)
    MULT_TOP: GF_MUL2_4BIT
        port map (
            x => t0, 
            y => m0  
        );

    MULT_BOTTOM: GF_MUL2_4BIT
        port map (
            x => t1, 
            y => m1  
        );

    -- 4. Cross-XOR logic (t0 xor m1 and t1 xor m0)
    z0 <= t0 xor m1;
    z1 <= t1 xor m0;

    -- 5. Second layer of SS boxes
    y0 <= SS2_ROM(to_integer(unsigned(z0)));
    y1 <= SS3_ROM(to_integer(unsigned(z1)));

    -- 6. Recombine output
    y <= y0 & y1;
end behavioral;