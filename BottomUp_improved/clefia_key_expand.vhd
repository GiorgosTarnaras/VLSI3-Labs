library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Package Definition for Round Key Array
package CLEFIA_TYPES is
    -- 36 Round Keys, each 32 bits wide
    type rk_array is array (0 to 35) of std_logic_vector(31 downto 0);
end package CLEFIA_TYPES;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.CLEFIA_TYPES.ALL;

entity CLEFIA_KEY_EXPAND_128 is
    Port ( 
        K  : in  std_logic_vector (127 downto 0); -- 128-bit Key
        L  : in  std_logic_vector (127 downto 0); -- 128-bit Intermediate Key
        WK : out std_logic_vector (127 downto 0); -- Whitening Keys (WK0-WK3)
        RK : out rk_array                         -- Round Keys (RK0-RK35)
    );
end CLEFIA_KEY_EXPAND_128;

architecture Structural of CLEFIA_KEY_EXPAND_128 is

    -- Component Declaration: Imports the CON values from your con_table.vhd
    component CON_TABLE is
        Port ( index   : in  integer range 0 to 59;
               con_val : out std_logic_vector (31 downto 0));
    end component;

    -- Component Declaration: Imports the DoubleSwap function from your double_swap.vhd
    component CLEFIA_DOUBLE_SWAP is
        Port ( input  : in  std_logic_vector (127 downto 0);
               output : out std_logic_vector (127 downto 0));
    end component;

    -- Signals for the L pipeline (Stages 0 to 9)
    type l_pipeline_type is array (0 to 9) of std_logic_vector(127 downto 0);
    signal L_wire : l_pipeline_type;

begin

    WK <= K;

    -- Initialize the L pipeline with the input L
    L_wire(0) <= L;

    -- Step 3: Loop for i = 0 to 8 
    GEN_EXPANSION_LOOP: for i in 0 to 8 generate
        
        -- Signals for this iteration
        signal con_0, con_1, con_2, con_3 : std_logic_vector(31 downto 0);
        signal con_combined : std_logic_vector(127 downto 0);
        signal T_temp       : std_logic_vector(127 downto 0);
        signal T_final      : std_logic_vector(127 downto 0);
        
        -- Indices for CON table lookups
        constant idx_0 : integer := 24 + (4 * i);
        constant idx_1 : integer := 24 + (4 * i) + 1;
        constant idx_2 : integer := 24 + (4 * i) + 2;
        constant idx_3 : integer := 24 + (4 * i) + 3;

    begin
        -- Import CON values for this stage (4 constants per stage) [cite: 510]
        U_CON_0: CON_TABLE port map (index => idx_0, con_val => con_0);
        U_CON_1: CON_TABLE port map (index => idx_1, con_val => con_1);
        U_CON_2: CON_TABLE port map (index => idx_2, con_val => con_2);
        U_CON_3: CON_TABLE port map (index => idx_3, con_val => con_3);

        -- Concatenate constants to form 128-bit block
        con_combined <= con_0 & con_1 & con_2 & con_3;

        T_temp <= L_wire(i) xor con_combined;

        -- Odd iterations are 1, 3, 5, 7.
        GEN_XOR_ODD: if (i mod 2) /= 0 generate
            T_final <= T_temp xor K;
        end generate GEN_XOR_ODD;

        -- Even iterations: T remains unchanged
        GEN_NO_XOR_EVEN: if (i mod 2) = 0 generate
            T_final <= T_temp;
        end generate GEN_NO_XOR_EVEN;

        U_DSWAP: CLEFIA_DOUBLE_SWAP 
            port map (input => L_wire(i), output => L_wire(i+1));

        -- Splits T (128-bit) into 4 Round Keys (32-bit each)
        RK(4*i)     <= T_final(127 downto 96);
        RK(4*i + 1) <= T_final(95 downto 64);
        RK(4*i + 2) <= T_final(63 downto 32);
        RK(4*i + 3) <= T_final(31 downto 0);

    end generate GEN_EXPANSION_LOOP;

end Structural;
