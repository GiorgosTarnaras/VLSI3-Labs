library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CLEFIA_S1 is
    Port ( x : in  std_logic_vector (7 downto 0); -- x(7) is math x0 (MSB), x(0) is math x7
           y : out std_logic_vector (7 downto 0)); -- y(7) is math y0 (MSB), y(0) is math y7
end CLEFIA_S1;

architecture structural of CLEFIA_S1 is
    -- Intermediate signals
    signal stage1_out : std_logic_vector(7 downto 0);
    signal inv_out    : std_logic_vector(7 downto 0);

    -- Inversion Core Signals (3 downto 0)
    signal a0, a1        : std_logic_vector(3 downto 0); -- a0=high nibble, a1=low nibble
    signal b0, b1        : std_logic_vector(3 downto 0);
    signal sum_a         : std_logic_vector(3 downto 0);
    signal a0_sq         : std_logic_vector(3 downto 0);
    signal a0_sq_lam     : std_logic_vector(3 downto 0);
    signal delta_mul     : std_logic_vector(3 downto 0);
    signal delta         : std_logic_vector(3 downto 0);
    signal inv_delta     : std_logic_vector(3 downto 0);

    -- Your Multiplier Component
    component GF_MUL_4BIT 
        Port ( v, w : in  std_logic_vector (3 downto 0);
               y    : out std_logic_vector (3 downto 0));
    end component;

begin

    ---------------------------------------------------------------------------
    -- STAGE 1: Initial Merged Transformation (phi o f)
    -- Note: Math index 'i' corresponds to VHDL index '7-i'
    ---------------------------------------------------------------------------
    -- Math: y0 = x7 + 0             --> VHDL: st1(7) <= x(0)
    stage1_out(7) <= x(0);                                     
    -- Math: y1 = x6 + 1             --> VHDL: st1(6) <= x(1) + 1
    stage1_out(6) <= x(1) xor '1';                               
    -- Math: y2 = x4 + x5 + 1        --> VHDL: st1(5) <= x(3) + x(2) + 1
    stage1_out(5) <= x(3) xor x(2) xor '1';                    
    -- Math: y3 = x3 + x6 + 0        --> VHDL: st1(4) <= x(4) + x(1)
    stage1_out(4) <= x(4) xor x(1);                            
    -- Math: y4 = x2 + 0             --> VHDL: st1(3) <= x(5)
    stage1_out(3) <= x(5);                                     
    -- Math: y5 = x1 + 1             --> VHDL: st1(2) <= x(6) + 1
    stage1_out(2) <= x(6) xor '1';                               
    -- Math: y6 = x5 + x7 + 0        --> VHDL: st1(1) <= x(2) + x(0)
    stage1_out(1) <= x(2) xor x(0);                            
    -- Math: y7 = x0 + x3 + 1        --> VHDL: st1(0) <= x(7) + x(4) + 1
    stage1_out(0) <= x(7) xor x(4) xor '1';                    

    ---------------------------------------------------------------------------
    -- STAGE 2: Inversion over GF((2^4)^2)
    ---------------------------------------------------------------------------
    a0 <= stage1_out(7 downto 4); -- High nibble corresponds to y0..y3
    a1 <= stage1_out(3 downto 0); -- Low nibble corresponds to y4..y7

    sum_a <= a0 xor a1;
    
    -- Corrected Square (z^4+z+1)
    a0_sq <= a0(3) & (a0(3) xor a0(1)) & a0(2) & (a0(2) xor a0(0));
    
    -- lambda * a0^2 in GF(2^4) where lambda = 0x8 ("1000")
    MUL_LAMBDA: GF_MUL_4BIT 
        port map(
            v => a0_sq,
            w => "1000", 
            y => a0_sq_lam
        );
    
    -- (a0 + a1) * a1
    MUL_DELTA: GF_MUL_4BIT 
        port map(
            v => sum_a,
            w => a1,
            y => delta_mul
        );

    -- Delta = (a0 + a1)a1 + lambda * a0^2
    delta <= delta_mul xor a0_sq_lam;

    -- Corrected Inversion LUT for GF(2^4) with P(z) = z^4+z+1
    with delta select
        inv_delta <= x"0" when x"0", 
                     x"1" when x"1", 
                     x"9" when x"2", 
                     x"E" when x"3",
                     x"D" when x"4", 
                     x"B" when x"5",
                     x"7" when x"6",
                     x"6" when x"7",
                     x"F" when x"8",
                     x"2" when x"9", 
                     x"C" when x"A",
                     x"5" when x"B",
                     x"A" when x"C",
                     x"4" when x"D", 
                     x"3" when x"E", 
                     x"8" when x"F",
                     x"0" when others;

    -- b0 = a0 * delta_inv
    MUL_B0: GF_MUL_4BIT 
        port map(
            v => a0,
            w => inv_delta,
            y => b0
        );

    -- b1 = (a0 + a1) * delta_inv
    MUL_B1: GF_MUL_4BIT 
        port map(
            v => sum_a,
            w => inv_delta,
            y => b1
        );
    
    -- Combine nibbles
    inv_out <= b0 & b1;

    ---------------------------------------------------------------------------
    -- STAGE 3: Final Merged Transformation (g o phi^-1)
    -- Note: Math index 'i' corresponds to VHDL index '7-i'
    -- 'inv_out' represents the mathematical vector 'z'
    ---------------------------------------------------------------------------
    -- Math: y0 = z6 + 0             --> VHDL: y(7) <= inv(1)
    y(7) <= inv_out(1);                                          
    -- Math: y1 = z5 + z7 + 1        --> VHDL: y(6) <= inv(2) + inv(0) + 1
    y(6) <= inv_out(2) xor inv_out(0) xor '1';                   
    -- Math: y2 = z3 + z4 + 1        --> VHDL: y(5) <= inv(4) + inv(3) + 1
    y(5) <= inv_out(4) xor inv_out(3) xor '1';                   
    -- Math: y3 = z0 + 0             --> VHDL: y(4) <= inv(7)
    y(4) <= inv_out(7);                                          
    -- Math: y4 = z1 + z6 + 1        --> VHDL: y(3) <= inv(6) + inv(1) + 1
    y(3) <= inv_out(6) xor inv_out(1) xor '1';                   
    -- Math: y5 = z4 + z5 + 0        --> VHDL: y(2) <= inv(3) + inv(2)
    y(2) <= inv_out(3) xor inv_out(2);                           
    -- Math: y6 = z2 + z3 + 0        --> VHDL: y(1) <= inv(5) + inv(4)
    y(1) <= inv_out(5) xor inv_out(4);                           
    -- Math: y7 = z0 + z2 + 1        --> VHDL: y(0) <= inv(7) + inv(5) + 1
    y(0) <= inv_out(7) xor inv_out(5) xor '1';                   

end structural;