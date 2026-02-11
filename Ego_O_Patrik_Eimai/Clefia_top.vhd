library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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

    -- =========================================================
    -- LOCAL TYPE DEFINITIONS
    -- =========================================================
    -- Defined locally instead of in an external package
    type rk_array is array (0 to 35) of std_logic_vector(31 downto 0);

    -- =========================================================
    -- COMPONENT DECLARATIONS
    -- =========================================================

    component CON_TABLE is
        Port ( index   : in  integer range 0 to 59;
               con_val : out std_logic_vector (31 downto 0));
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

    component CLEFIA_Key_Row_Gen is
        Port ( 
            L_curr  : in  STD_LOGIC_VECTOR (127 downto 0); 
            K       : in  STD_LOGIC_VECTOR (127 downto 0); 
            counter : in  integer range 0 to 8;            
            RK_Row  : out STD_LOGIC_VECTOR (127 downto 0); 
            L_next  : out STD_LOGIC_VECTOR (127 downto 0) 
        );
    end component;

    -- =========================================================
    -- SIGNALS & REGISTERS
    -- =========================================================

    type state_type is (IDLE, KS_L_GEN, KS_L_PERM, KS_EXPAND, PRE_WHITE, ROUNDS, POST_WHITE, FINISH);
    signal state : state_type;

    -- Data Registers
    signal reg_data : std_logic_vector(127 downto 0); 
    signal reg_key  : std_logic_vector(127 downto 0); 
    signal reg_L    : std_logic_vector(127 downto 0); 
    
    -- Round Keys Storage (Using local type)
    signal rk_storage : rk_array;
    signal wk0, wk1, wk2, wk3 : std_logic_vector(31 downto 0); 

    -- Counters
    signal ks_ctr    : integer range 0 to 12; 
    signal round_ctr : integer range 0 to 18; 
    signal mode_dec  : std_logic;

    -- Safe Counter for Key Expansion (Fixes the 300ns crash)
    signal safe_exp_ctr : integer range 0 to 8;

    -- Signals for L-Generation
    signal l_gen_con0, l_gen_con1 : std_logic_vector(31 downto 0);
    signal l_gen_idx0, l_gen_idx1 : integer range 0 to 59;
    signal l_gen_out              : std_logic_vector(127 downto 0);

    -- Signals for Expansion
    signal exp_rk_row : std_logic_vector(127 downto 0);
    signal exp_l_next : std_logic_vector(127 downto 0);

    -- Signals for Rounds
    signal current_rk0, current_rk1 : std_logic_vector(31 downto 0);
    signal round_out_enc : std_logic_vector(127 downto 0);
    signal round_out_dec : std_logic_vector(127 downto 0);

begin

    -- Whitening Keys
    wk0 <= reg_key(127 downto 96);
    wk1 <= reg_key(95 downto 64);
    wk2 <= reg_key(63 downto 32);
    wk3 <= reg_key(31 downto 0);

    -- =========================================================
    -- 1. L-GENERATION LOGIC
    -- =========================================================
    -- Indices for CON table
    l_gen_idx0 <= 2 * ks_ctr when ks_ctr <= 11 else 0;
    l_gen_idx1 <= (2 * ks_ctr) + 1 when ks_ctr <= 11 else 0;

    -- Two CON Tables for L-Gen
    U_CON_L0: CON_TABLE port map (index => l_gen_idx0, con_val => l_gen_con0);
    U_CON_L1: CON_TABLE port map (index => l_gen_idx1, con_val => l_gen_con1);

    -- Single Round instance for L-Gen
    U_ROUND_L_GEN: CLEFIA_ROUND port map (
        data_in  => reg_L,       
        rk0      => l_gen_con0,  
        rk1      => l_gen_con1,  
        data_out => l_gen_out    
    );

    -- =========================================================
    -- 2. KEY EXPANSION LOGIC
    -- =========================================================
    -- Safety Logic: Ensure counter is 0 if we aren't in Expansion phase or if counter > 8
    -- This prevents the "Range Constraint Failure" at 300ns.
    safe_exp_ctr <= ks_ctr when (state = KS_EXPAND and ks_ctr <= 8) else 0;

    U_KEY_EXP_ROW: CLEFIA_Key_Row_Gen port map (
        L_curr  => reg_L,
        K       => reg_key,
        counter => safe_exp_ctr, -- Use clamped counter
        RK_Row  => exp_rk_row,  
        L_next  => exp_l_next   
    );

    -- =========================================================
    -- 3. DATA PROCESSING LOGIC
    -- =========================================================
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

    -- =========================================================
    -- 4. ROUND KEY SELECTION PROCESS
    -- =========================================================
    process(round_ctr, mode_dec, rk_storage)
        variable idx0_v, idx1_v : integer;
    begin
        if mode_dec = '0' then
            -- Encrypt: RK indices 0,1 -> 2,3 ...
            idx0_v := 2 * round_ctr;
            idx1_v := (2 * round_ctr) + 1;
        else
            -- Decrypt: Reverse order (17 down to 0)
            idx0_v := 2 * (17 - round_ctr);
            idx1_v := (2 * (17 - round_ctr)) + 1;
        end if;
        
        -- Bounds check
        if idx0_v < 0 then idx0_v := 0; end if;
        if idx0_v > 35 then idx0_v := 35; end if;
        if idx1_v < 0 then idx1_v := 0; end if;
        if idx1_v > 35 then idx1_v := 35; end if;

        current_rk0 <= rk_storage(idx0_v);
        current_rk1 <= rk_storage(idx1_v);
    end process;

    -- =========================================================
    -- 5. MAIN FINITE STATE MACHINE (FSM)
    -- =========================================================
    process(clk, rst)
        variable t0, t1, t2, t3 : std_logic_vector(31 downto 0);
    begin
        if rst = '1' then
            state     <= IDLE;
            reg_data  <= (others => '0');
            reg_key   <= (others => '0');
            reg_L     <= (others => '0');
            data_out  <= (others => '0');
            done      <= '0';
            round_ctr <= 0;
            ks_ctr    <= 0;
            mode_dec  <= '0';
            for i in 0 to 35 loop
                rk_storage(i) <= (others => '0');
            end loop;

        elsif rising_edge(clk) then
            case state is
                
                when IDLE =>
                    done <= '0';
                    if start = '1' then
                        reg_key  <= key_in;
                        reg_data <= data_in;
                        mode_dec <= is_decrypt;
                        
                        -- L starts as K
                        reg_L    <= key_in;
                        ks_ctr   <= 0;
                        state    <= KS_L_GEN;
                    end if;

                -- Phase 1: Generate L (12 Rounds)
                when KS_L_GEN =>
                    reg_L <= l_gen_out; 
                    
                    if ks_ctr = 11 then
                        ks_ctr <= 0;
                        state  <= KS_L_PERM;
                    else
                        ks_ctr <= ks_ctr + 1;
                    end if;

                -- Phase 1.5: Final Permutation of L
                when KS_L_PERM =>
                    -- Rotate: T1|T2|T3|T0 -> T0|T1|T2|T3
                    reg_L <= reg_L(31 downto 0) & reg_L(127 downto 32);
                    ks_ctr <= 0;
                    state  <= KS_EXPAND;

                -- Phase 2: Key Expansion (9 Iterations)
                when KS_EXPAND =>
                    -- Store generated keys
                    rk_storage(4 * ks_ctr)     <= exp_rk_row(127 downto 96);
                    rk_storage(4 * ks_ctr + 1) <= exp_rk_row(95 downto 64);
                    rk_storage(4 * ks_ctr + 2) <= exp_rk_row(63 downto 32);
                    rk_storage(4 * ks_ctr + 3) <= exp_rk_row(31 downto 0);

                    -- Update L
                    reg_L <= exp_l_next;

                    if ks_ctr = 8 then
                        state <= PRE_WHITE;
                    else
                        ks_ctr <= ks_ctr + 1;
                    end if;

                -- Phase 3: Data Processing
                when PRE_WHITE =>
                    t0 := reg_data(127 downto 96);
                    t1 := reg_data(95 downto 64);
                    t2 := reg_data(63 downto 32);
                    t3 := reg_data(31 downto 0);

                    if mode_dec = '0' then
                        t1 := t1 xor wk0;
                        t3 := t3 xor wk1;
                    else
                        t1 := t1 xor wk2;
                        t3 := t3 xor wk3;
                    end if;

                    reg_data  <= t0 & t1 & t2 & t3;
                    round_ctr <= 0;
                    state     <= ROUNDS;

                when ROUNDS =>
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

                    done  <= '1';
                    state <= FINISH;

                when FINISH =>
                    if start = '0' then
                        done  <= '0';
                        state <= IDLE;
                    end if;

            end case;
        end if;
    end process;

end Behavioral;