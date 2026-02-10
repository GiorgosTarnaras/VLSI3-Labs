library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- Use the package defined in clefia_key_expand.vhd for the RK array type
use work.CLEFIA_TYPES.ALL;

entity CLEFIA_128_CORE is
    Port ( 
        clk        : in  std_logic;
        rst        : in  std_logic;
        start      : in  std_logic;
        is_decrypt : in  std_logic; -- 0: Encryption, 1: Decryption
        key_in     : in  std_logic_vector (127 downto 0);
        data_in    : in  std_logic_vector (127 downto 0);
        data_out   : out std_logic_vector (127 downto 0);
        done       : out std_logic
    );
end CLEFIA_128_CORE;

architecture Behavioral of CLEFIA_128_CORE is

    -- COMPONENT DECLARATIONS
    
    component CLEFIA_KEY_EXPAND_128 is
        Port ( 
            K  : in  std_logic_vector (127 downto 0);
            L  : in  std_logic_vector (127 downto 0);
            WK : out std_logic_vector (127 downto 0);
            RK : out rk_array
        );
    end component;
    
    component CLEFIA_L_GEN is
        Port ( 
            K : in  std_logic_vector (127 downto 0);
            L : out std_logic_vector (127 downto 0)
        );
    end component;

    component CLEFIA_ROUND is
        Port ( 
            data_in  : in  std_logic_vector (127 downto 0); 
            rk0      : in  std_logic_vector (31 downto 0);  
            rk1      : in  std_logic_vector (31 downto 0);  
            data_out : out std_logic_vector (127 downto 0)  
        );
    end component;

    component CLEFIA_ROUND_INV is
        Port ( 
            data_in  : in  std_logic_vector (127 downto 0); 
            rk0      : in  std_logic_vector (31 downto 0);  
            rk1      : in  std_logic_vector (31 downto 0);  
            data_out : out std_logic_vector (127 downto 0)  
        );
    end component;

    -- SIGNALS

    -- FSM State
    type state_type is (IDLE, PRE_WHITE, ROUNDS, POST_WHITE, FINISH);
    signal state : state_type;

    -- Data Registers
    signal reg_data : std_logic_vector(127 downto 0);
    signal reg_key  : std_logic_vector(127 downto 0);
    signal mode_dec : std_logic; -- Latched mode
    signal round_ctr : integer range 0 to 18;

    -- Key Expansion Signals
    signal L_inter : std_logic_vector(127 downto 0);
    signal WK_bus  : std_logic_vector(127 downto 0);
    signal RK_bus  : rk_array;
    
    -- Whitening Keys
    signal wk0, wk1, wk2, wk3 : std_logic_vector(31 downto 0);

    -- Round Logic Signals
    signal round_in     : std_logic_vector(127 downto 0);
    signal round_out_enc: std_logic_vector(127 downto 0);
    signal round_out_dec: std_logic_vector(127 downto 0);
    signal current_rk0  : std_logic_vector(31 downto 0);
    signal current_rk1  : std_logic_vector(31 downto 0);

begin

    -- =========================================================================
    -- 1. Key Expansion (Combinatorial)
    -- =========================================================================
    -- Generate L from K
    U_L_GEN: CLEFIA_L_GEN port map (
        K => reg_key,
        L => L_inter
    );

    -- Expand K and L into Round Keys (RK) and Whitening Keys (WK)
    U_KEY_EXP: CLEFIA_KEY_EXPAND_128 port map (
        K  => reg_key,
        L  => L_inter,
        WK => WK_bus,
        RK => RK_bus
    );
    wk0 <= WK_bus(127 downto 96);
    wk1 <= WK_bus(95 downto 64);
    wk2 <= WK_bus(63 downto 32);
    wk3 <= WK_bus(31 downto 0);

    -- =========================================================================
    -- 2. Round Instances
    -- =========================================================================
    -- We instantiate both Enc and Dec rounds and multiplex their inputs/outputs
    -- based on the mode.
    
    U_ROUND_ENC: CLEFIA_ROUND port map (
        data_in  => reg_data,
        rk0      => current_rk0,
        rk1      => current_rk1,
        data_out => round_out_enc
    );

    U_ROUND_DEC: CLEFIA_ROUND_INV port map (
        data_in  => reg_data,
        rk0      => current_rk0,
        rk1      => current_rk1,
        data_out => round_out_dec
    );

    -- =========================================================================
    -- 3. Round Key Selection Logic
    -- =========================================================================
    process(round_ctr, mode_dec, RK_bus)
        variable idx_0 : integer;
        variable idx_1 : integer;
    begin
        if mode_dec = '0' then
            -- ENCRYPTION: RK indices are 0,1 -> 2,3 ... -> 34,35
            idx_0 := 2 * round_ctr;
            idx_1 := (2 * round_ctr) + 1;
        else
            -- Total 18 rounds (0 to 17). 
            -- Round 0 uses RK34, RK35. Round 17 uses RK0, RK1.
            -- Formula: 2 * (17 - round_ctr)
            idx_0 := 2 * (17 - round_ctr);
            idx_1 := (2 * (17 - round_ctr)) + 1;
        end if;

        -- Prevent array out of bounds during IDLE/WHITE states
        if idx_0 < 0 then idx_0 := 0; end if; 
        if idx_0 > 35 then idx_0 := 35; end if;
        if idx_1 < 0 then idx_1 := 0; end if;
        if idx_1 > 35 then idx_1 := 35; end if;

        current_rk0 <= RK_bus(idx_0);
        current_rk1 <= RK_bus(idx_1);
    end process;

    -- =========================================================================
    -- 4. FSM and Data Path
    -- =========================================================================
    process(clk, rst)
        variable t0, t1, t2, t3 : std_logic_vector(31 downto 0);
    begin
        if rst = '1' then
            state <= IDLE;
            reg_data <= (others => '0');
            reg_key  <= (others => '0');
            data_out <= (others => '0');
            done <= '0';
            round_ctr <= 0;
            mode_dec <= '0';
        elsif rising_edge(clk) then
            case state is
                
                when IDLE =>
                    done <= '0';
                    if start = '1' then
                        reg_key  <= key_in;
                        reg_data <= data_in;
                        mode_dec <= is_decrypt;
                        state    <= PRE_WHITE;
                    end if;

                when PRE_WHITE =>
                    -- Split current data
                    t0 := reg_data(127 downto 96);
                    t1 := reg_data(95 downto 64);
                    t2 := reg_data(63 downto 32);
                    t3 := reg_data(31 downto 0);

                    if mode_dec = '0' then
                        -- P0 | P1^WK0 | P2 | P3^WK1
                        t1 := t1 xor wk0;
                        t3 := t3 xor wk1;
                    else
                        -- C0 | C1^WK2 | C2 | C3^WK3
                        t1 := t1 xor wk2;
                        t3 := t3 xor wk3;
                    end if;

                    reg_data <= t0 & t1 & t2 & t3;
                    round_ctr <= 0;
                    state <= ROUNDS;

                when ROUNDS =>
                    -- Round Logic applied via components (U_ROUND_ENC / U_ROUND_DEC)
                    -- Update register with the result of the combinational components
                    if mode_dec = '0' then
                        reg_data <= round_out_enc;
                    else
                        reg_data <= round_out_dec;
                    end if;

                    if round_ctr = 17 then
                        state <= POST_WHITE;
                    else
                        round_ctr <= round_ctr + 1;
                    end if;

                when POST_WHITE =>
                   

                    if mode_dec = '0' then
						t0 := reg_data(31 downto 0);
						t1 := reg_data(127 downto 96);
						t2 := reg_data(95 downto 64);
						t3 := reg_data(63 downto 32);
                        data_out <= t0 & (t1 xor wk2) & t2 & (t3 xor wk3);
                    else
						t0 := reg_data(95 downto 64);
						t1 := reg_data(63 downto 32);
						t2 := reg_data(31 downto 0);
						t3 := reg_data(127 downto 96);
                        data_out <= t0 & (t1 xor wk0) & t2 & (t3 xor wk1);
                    end if;

                    done <= '1';
                    state <= FINISH;

                when FINISH =>
                    -- Wait for start to go low or just return to IDLE
                    if start = '0' then
                        done <= '0';
                        state <= IDLE;
                    end if;

            end case;
        end if;
    end process;

end Behavioral;
