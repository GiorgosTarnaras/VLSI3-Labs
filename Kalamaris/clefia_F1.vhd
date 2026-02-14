library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CLEFIA_F1 is
    Port ( rk     : in  std_logic_vector (31 downto 0); 
           x      : in  std_logic_vector (31 downto 0); 
           y      : out std_logic_vector (31 downto 0));
end CLEFIA_F1;

architecture structural of CLEFIA_F1 is

    component CLEFIA_S0 is 
        port(x: in std_logic_vector(7 downto 0); y: out std_logic_vector(7 downto 0)); 
    end component;
    
    component CLEFIA_S1 is 
        port(x: in std_logic_vector(7 downto 0); y: out std_logic_vector(7 downto 0)); 
    end component;
    
    component CLEFIA_M1 is 
        port(input: in std_logic_vector(31 downto 0); output: out std_logic_vector(31 downto 0)); 
    end component;

    signal temp_xor : std_logic_vector(31 downto 0);
    signal sbox_in0, sbox_in1, sbox_in2, sbox_in3 : std_logic_vector(7 downto 0);
    signal sbox_out0, sbox_out1, sbox_out2, sbox_out3 : std_logic_vector(7 downto 0);
    signal matrix_in : std_logic_vector(31 downto 0);

begin
    
    temp_xor <= rk xor x;

    sbox_in0 <= temp_xor(31 downto 24);
    sbox_in1 <= temp_xor(23 downto 16);
    sbox_in2 <= temp_xor(15 downto 8);
    sbox_in3 <= temp_xor(7 downto 0);

    -- S-Boxes (S1, S0, S1, S0)
    U_S1_0: CLEFIA_S1 port map (x => sbox_in0, y => sbox_out0);
    U_S0_1: CLEFIA_S0 port map (x => sbox_in1, y => sbox_out1);
    U_S1_2: CLEFIA_S1 port map (x => sbox_in2, y => sbox_out2);
    U_S0_3: CLEFIA_S0 port map (x => sbox_in3, y => sbox_out3);

    matrix_in <= sbox_out0 & sbox_out1 & sbox_out2 & sbox_out3;

    U_M1: CLEFIA_M1 port map (input => matrix_in, output => y);

end structural;