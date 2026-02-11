library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Entity Definition
-- Inputs: Current L, Master K, and the Row Counter (0-8)
-- Outputs: The 128-bit Round Key row (RK) and the next L value
entity CLEFIA_Key_Row_Gen is
    Port ( 
        L_curr  : in  STD_LOGIC_VECTOR (127 downto 0); -- Current value of L
        K       : in  STD_LOGIC_VECTOR (127 downto 0); -- Master Key K
        counter : in  integer range 0 to 8;            -- Loop index 'i' from algorithm
        RK_Row  : out STD_LOGIC_VECTOR (127 downto 0); -- Output RK for this row (e.g. RK0-3)
        L_next  : out STD_LOGIC_VECTOR (127 downto 0)  -- Sigma(L) for the next round
    );
end CLEFIA_Key_Row_Gen;

architecture Behavioral of CLEFIA_Key_Row_Gen is

    -- Declare the Constant Table component [cite: 2]
    component CON_TABLE
        Port ( index   : in  integer range 0 to 59;
               con_val : out std_logic_vector (31 downto 0));
    end component;

    -- Declare the Double Swap (Sigma) component [cite: 7]
    component CLEFIA_DOUBLE_SWAP
        Port ( input   : in  std_logic_vector (127 downto 0);
               output  : out std_logic_vector (127 downto 0));
    end component;

    -- Internal signals
    signal con0, con1, con2, con3 : std_logic_vector(31 downto 0);
    signal con_full : std_logic_vector(127 downto 0);
    signal T        : std_logic_vector(127 downto 0);
    signal base_idx : integer range 0 to 59;

begin

    -- 1. Fetch Constant Values
    -- According to Step 3, constants start at index 24 and increment by 4*i 
    base_idx <= 24 + (4 * counter);

    -- Instantiate 4 lookups to build the 128-bit Constant Block
    C0: CON_TABLE port map (index => base_idx,     con_val => con0);
    C1: CON_TABLE port map (index => base_idx + 1, con_val => con1);
    C2: CON_TABLE port map (index => base_idx + 2, con_val => con2);
    C3: CON_TABLE port map (index => base_idx + 3, con_val => con3);

    -- Concatenate constants to form the 128-bit XOR mask
    con_full <= con0 & con1 & con2 & con3;

    -- 2. Calculate Intermediate Value T
    -- T <- L XOR (CON | CON | CON | CON) 
    T <= L_curr xor con_full;

    -- 3. Update L for the next iteration
    -- L <- Sigma(L) 
    -- We use the DoubleSwap component to calculate the L for the next round.
    Sigma_Calc: CLEFIA_DOUBLE_SWAP port map (
        input  => L_curr, 
        output => L_next
    );

    -- 4. Generate Round Keys (Conditional XOR)
    -- "if i is odd: T <- T XOR K" 
    process(T, K, counter)
    begin
        if (counter mod 2 /= 0) then
            -- Odd Rows (1, 3, 5, 7): XOR with K
            RK_Row <= T xor K;
        else
            -- Even Rows (0, 2, 4, 6, 8): Keep T as is
            RK_Row <= T;
        end if;
    end process;

end Behavioral;