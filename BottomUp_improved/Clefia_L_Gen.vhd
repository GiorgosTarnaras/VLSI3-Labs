library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CLEFIA_L_GEN is
    Port ( 
        K : in  std_logic_vector (127 downto 0); -- Input Key K
        L : out std_logic_vector (127 downto 0)  -- Output Intermediate Key L
    );
end CLEFIA_L_GEN;

architecture Structural of CLEFIA_L_GEN is

    component CLEFIA_ROUND is
        Port ( 
            data_in  : in  std_logic_vector (127 downto 0); 
            rk0      : in  std_logic_vector (31 downto 0);  
            rk1      : in  std_logic_vector (31 downto 0);  
            data_out : out std_logic_vector (127 downto 0)  
        );
    end component;

    component CON_TABLE is
        Port ( index   : in  integer range 0 to 59;
               con_val : out std_logic_vector (31 downto 0));
    end component;

    -- Signals for connecting the 12 rounds
    -- We need 13 stages: 0 (Input) to 12 (Output)
    type round_data_type is array (0 to 12) of std_logic_vector(127 downto 0);
    signal round_data : round_data_type;

begin

    -- Initialize stage 0 with Input K
    round_data(0) <= K;

    -- Generate 12 Rounds of GFN
    GEN_ROUNDS: for i in 0 to 11 generate
        signal rk_0 : std_logic_vector(31 downto 0);
        signal rk_1 : std_logic_vector(31 downto 0);
        constant idx_0 : integer := 2 * i;
        constant idx_1 : integer := (2 * i) + 1;
    begin
        U_CON_A: CON_TABLE port map (index => idx_0, con_val => rk_0);
        U_CON_B: CON_TABLE port map (index => idx_1, con_val => rk_1);

        -- Instantiate Round Function
        -- CLEFIA_ROUND performs the F0/F1 operations and the cyclic swap (Step 2.2)
        U_ROUND: CLEFIA_ROUND port map (
            data_in  => round_data(i),
            rk0      => rk_0,
            rk1      => rk_1,
            data_out => round_data(i+1)
        );
    end generate GEN_ROUNDS;
    
    L <= round_data(12)(31 downto 0) & -- T0
         round_data(12)(127 downto 96)  & -- T1
         round_data(12)(95 downto 64) & -- T2
         round_data(12)(63 downto 32);   -- T3

end Structural;
