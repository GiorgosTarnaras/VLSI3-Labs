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

    -- Embedded Constant Table [cite: 602-606]
    type con_array_type is array (0 to 59) of std_logic_vector(31 downto 0);
    constant CON : con_array_type := (
        x"f56b7aeb", x"994a8a42", x"96a4bd75", x"fa854521", -- 0-3
        x"735b768a", x"1f7abac4", x"d5bc3b45", x"b99d5d62", -- 4-7
        x"52d73592", x"3ef636e5", x"c57a1ac9", x"a95b9b72", -- 8-11
        x"5ab42554", x"369555ed", x"1553ba9a", x"7972b2a2", -- 12-15
        x"e6b85d4d", x"8a995951", x"4b550696", x"2774b4fc", -- 16-19
        x"c9bb034b", x"a59a5a7e", x"88cc81a5", x"e4ed2d3f", -- 20-23
        x"7c6f68e2", x"104e8ecb", x"d2263471", x"be07c765", -- 24-27
        x"511a3208", x"3d3bfbe6", x"1084b134", x"7ca565a7", -- 28-31
        x"304bf0aa", x"5c6aaa87", x"f4347855", x"9815d543", -- 32-35
        x"4213141a", x"2e32f2f5", x"cd180a0d", x"a139f97a", -- 36-39
        x"5e852d36", x"32a464e9", x"c353169b", x"af72b274", -- 40-43
        x"8db88b4d", x"e199593a", x"7ed56d96", x"12f434c9", -- 44-47
        x"d37b36cb", x"bf5a9a64", x"85ac9b65", x"e98d4d32", -- 48-51
        x"7adf6582", x"16fe3ecd", x"d17e32c1", x"bd5f9f66", -- 52-55
        x"50b63150", x"3c9757e7", x"1052b098", x"7c73b3a7"  -- 56-59
    );

    -- =========================================================
    -- COMPONENT DECLARATIONS
    -- =========================================================
    component CLEFIA_ROUND is
        Port ( 
            data_in  : in  std_logic_vector (127 downto 0); 
            rk0      : in  std_logic_vector (31 downto 0);  
            rk1      : in  std_logic_vector (31 downto 0);
            mode     : in  std_logic; 
            data_out : out std_logic_vector (127 downto 0)  
        );
    end component;

    component CLEFIA_Key_Row_Gen is
        Port ( 
            L       : in  STD_LOGIC_VECTOR (127 downto 0); 
            con0    : in  STD_LOGIC_VECTOR (31 downto 0);
            con1    : in  STD_LOGIC_VECTOR (31 downto 0);
            con2    : in  STD_LOGIC_VECTOR (31 downto 0);
            con3    : in  STD_LOGIC_VECTOR (31 downto 0);
            K       : in  STD_LOGIC_VECTOR (127 downto 0); 
            counter : in  integer range 0 to 8;            
            RK_Row  : out STD_LOGIC_VECTOR (127 downto 0) 
        );
    end component;

    component CLEFIA_DOUBLE_SWAP is
        Port ( input  : in  std_logic_vector (127 downto 0);
               output : out std_logic_vector (127 downto 0));
    end component;

    component CLEFIA_8_DOUBLE_SWAP is
        Port ( input  : in  std_logic_vector (127 downto 0);
               output : out std_logic_vector (127 downto 0));
    end component;

    component CLEFIA_INV_DOUBLE_SWAP is
        Port ( input  : in  std_logic_vector (127 downto 0);
               output : out std_logic_vector (127 downto 0));
    end component;

    -- =========================================================
    -- SIGNALS
    -- =========================================================
    type state_type is (IDLE, GEN_L, SETUP, ROUNDS, FINISH);
    signal current_state, next_state : state_type;

    signal reg_data       : std_logic_vector(127 downto 0);
    signal reg_key        : std_logic_vector(127 downto 0); 
    signal reg_L          : std_logic_vector(127 downto 0);
    signal current_rk_reg : std_logic_vector(127 downto 0); -- Replaces rk_storage array
    signal wk0, wk1, wk2, wk3 : std_logic_vector(31 downto 0); 

    signal ks_ctr    : integer range 0 to 12;
    signal round_ctr : integer range 0 to 18; 
    signal mode_dec  : std_logic;

    signal enc_exp_ctr      : integer range 0 to 9; 
    signal dec_exp_ctr      : integer range -1 to 9; 
    signal active_exp_ctr   : integer range 0 to 8;

    signal idx_L0, idx_L1     : integer range 0 to 59;
    signal idx_k_con0, idx_k_con1, idx_k_con2, idx_k_con3 : integer range 0 to 59;

    signal current_rk_row   : std_logic_vector(127 downto 0);
    signal fwd_l_next       : std_logic_vector(127 downto 0);
    signal inv_l_next       : std_logic_vector(127 downto 0);
    signal bridge_in        : std_logic_vector(127 downto 0);
    signal l_sigma8_out     : std_logic_vector(127 downto 0);
    
    signal round_data_in_sig  : std_logic_vector(127 downto 0);
    signal round_rk0_sig      : std_logic_vector(31 downto 0);
    signal round_rk1_sig      : std_logic_vector(31 downto 0);
    signal round_mode_sig     : std_logic;
    signal round_out_shared   : std_logic_vector(127 downto 0);
     
begin

    wk0 <= reg_key(127 downto 96); wk1 <= reg_key(95 downto 64);
    wk2 <= reg_key(63 downto 32);  wk3 <= reg_key(31 downto 0);

    -- Indices mapping
    idx_L0 <= 2 * ks_ctr;
    idx_L1 <= 2 * ks_ctr + 1;

    -- Secure tracking of the expansion counter bounds 
    active_exp_ctr <= enc_exp_ctr when (mode_dec = '0' and enc_exp_ctr <= 8) else 
                      dec_exp_ctr when (mode_dec = '1' and dec_exp_ctr >= 0) else 0;

    idx_k_con0 <= 24 + 4 * active_exp_ctr;
    idx_k_con1 <= 24 + 4 * active_exp_ctr + 1;
    idx_k_con2 <= 24 + 4 * active_exp_ctr + 2;
    idx_k_con3 <= 24 + 4 * active_exp_ctr + 3;

    -- Unified Key Generation Module directly accessing the CON array
    U_KEY_GEN: CLEFIA_Key_Row_Gen port map (
        L       => reg_L, 
        con0    => CON(idx_k_con0), 
        con1    => CON(idx_k_con1), 
        con2    => CON(idx_k_con2), 
        con3    => CON(idx_k_con3),
        K       => reg_key, 
        counter => active_exp_ctr, 
        RK_Row  => current_rk_row
    );

    -- L Register Update Submodules
    U_FWD_SWAP: CLEFIA_DOUBLE_SWAP port map (input => reg_L, output => fwd_l_next);
    U_INV_SWAP: CLEFIA_INV_DOUBLE_SWAP port map (input => reg_L, output => inv_l_next);

    -- The "un-swap" needed to derive the true L value from the final round
    bridge_in <= round_out_shared(31 downto 0) & round_out_shared(127 downto 32);
    U_SIGMA8: CLEFIA_8_DOUBLE_SWAP port map (input => bridge_in, output => l_sigma8_out);

    -- =========================================================
    -- Round Key Routing Combinational Logic
    -- =========================================================
    process(current_state, mode_dec, round_ctr, current_rk_reg, idx_L0, idx_L1)
    begin
        if current_state = GEN_L then
            round_rk0_sig <= CON(idx_L0);
            round_rk1_sig <= CON(idx_L1);
        else
            if mode_dec = '0' then -- Encryption Multiplexing
                if (round_ctr mod 2 = 0) then
                    round_rk0_sig <= current_rk_reg(127 downto 96);
                    round_rk1_sig <= current_rk_reg(95 downto 64);
                else
                    round_rk0_sig <= current_rk_reg(63 downto 32);
                    round_rk1_sig <= current_rk_reg(31 downto 0);
                end if;
            else -- Decryption Multiplexing (Reverse usage)
                if (round_ctr mod 2 = 0) then
                    round_rk0_sig <= current_rk_reg(63 downto 32);
                    round_rk1_sig <= current_rk_reg(31 downto 0);
                else
                    round_rk0_sig <= current_rk_reg(127 downto 96);
                    round_rk1_sig <= current_rk_reg(95 downto 64);
                end if;
            end if;
        end if;
    end process;

    round_data_in_sig <= reg_L when current_state = GEN_L else reg_data;
    round_mode_sig    <= '1' when current_state = GEN_L else not mode_dec;

    U_ROUND_SHARED: CLEFIA_ROUND port map (
        data_in => round_data_in_sig, rk0 => round_rk0_sig, rk1 => round_rk1_sig,
        mode => round_mode_sig, data_out => round_out_shared
    );

    -- =========================================================
    -- FSM PROCESS 1: Combinational Next-State Logic [cite: 536-570]
    -- =========================================================
    FSM_NEXT_STATE: process(current_state, start, ks_ctr, round_ctr)
    begin
        next_state <= current_state; 
        case current_state is
            when IDLE =>
                if start = '1' then next_state <= GEN_L; end if;
            when GEN_L =>
                if ks_ctr = 11 then next_state <= SETUP; end if;
            when SETUP =>
                next_state <= ROUNDS;
            when ROUNDS =>
                if round_ctr = 17 then next_state <= FINISH; end if;
            when FINISH =>
                if start = '0' then next_state <= IDLE; end if;
            when others =>
                next_state <= IDLE;
        end case;
    end process;

    -- =========================================================
    -- FSM PROCESS 2: Clocked Current State & Datapath [cite: 580-586]
    -- =========================================================
    FSM_SEQ: process(clk, rst)
        variable t0, t1, t2, t3 : std_logic_vector(31 downto 0);
        variable pw0, pw1, pw2, pw3 : std_logic_vector(31 downto 0);
    begin
        if rst = '1' then
            current_state <= IDLE;
            done <= '0';
            ks_ctr <= 0; round_ctr <= 0; enc_exp_ctr <= 0; dec_exp_ctr <= 0;
            reg_data <= (others => '0'); reg_key <= (others => '0'); reg_L <= (others => '0');
            current_rk_reg <= (others => '0');
        elsif rising_edge(clk) then
            current_state <= next_state; 

            case current_state is
                when IDLE =>
                    done <= '0';
                    if start = '1' then
                        reg_key <= key_in; reg_data <= data_in; mode_dec <= is_decrypt;
                        reg_L <= key_in; ks_ctr <= 0;
                    end if;

                when GEN_L =>
                    if ks_ctr = 11 then
                        ks_ctr <= 0;
                        if is_decrypt = '1' then
                            reg_L <= l_sigma8_out; 
                            dec_exp_ctr <= 8; 
                        else
                            reg_L <= bridge_in; 
                            enc_exp_ctr <= 0;
                        end if;
                    else
                        reg_L <= round_out_shared;
                        ks_ctr <= ks_ctr + 1;
                    end if;

                when SETUP =>
                    t0 := reg_data(127 downto 96); t1 := reg_data(95 downto 64);
                    t2 := reg_data(63 downto 32);  t3 := reg_data(31 downto 0);
                    
                    current_rk_reg <= current_rk_row; -- Fetch first row

                    if mode_dec = '0' then 
                        t1 := t1 xor wk0; t3 := t3 xor wk1;
                        reg_L <= fwd_l_next; 
                        enc_exp_ctr <= 1;
                    else 
                        t1 := t1 xor wk2; t3 := t3 xor wk3;
                        reg_L <= inv_l_next; 
                        dec_exp_ctr <= 7;
                    end if;
                    reg_data <= t0 & t1 & t2 & t3;
                    round_ctr <= 0; 

                when ROUNDS =>
                    reg_data <= round_out_shared;
                    
                    -- Only fetch the next row of keys on odd rounds
                    if (round_ctr mod 2 = 1) and (round_ctr < 17) then
                        current_rk_reg <= current_rk_row;
                        if mode_dec = '0' then
                            reg_L <= fwd_l_next; 
                            enc_exp_ctr <= enc_exp_ctr + 1;
                        else
                            reg_L <= inv_l_next; 
                            dec_exp_ctr <= dec_exp_ctr - 1;
                        end if;
                    end if;

                    if round_ctr = 17 then
                        done <= '1';
                        if mode_dec = '0' then
                            data_out <= round_out_shared(31 downto 0) & (round_out_shared(127 downto 96) xor wk2) & 
                                        round_out_shared(95 downto 64) & (round_out_shared(63 downto 32) xor wk3);
                        else
                            pw0 := round_out_shared(95 downto 64);
                            pw1 := round_out_shared(63 downto 32);
                            pw2 := round_out_shared(31 downto 0);
                            pw3 := round_out_shared(127 downto 96);
                            data_out <= pw0 & (pw1 xor wk0) & pw2 & (pw3 xor wk1);
                        end if;
                    else
                        round_ctr <= round_ctr + 1;
                    end if;

                when FINISH =>
                    if start = '0' then done <= '0'; end if;
                when others => 
            end case;
        end if;
    end process;
end Behavioral;