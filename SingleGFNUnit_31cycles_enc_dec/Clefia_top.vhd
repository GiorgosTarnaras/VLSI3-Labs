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
            mode     : in  std_logic; 
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

    component CLEFIA_INV_RK_GEN is
        Port ( 
            L_curr  : in  STD_LOGIC_VECTOR (127 downto 0); 
            K       : in  STD_LOGIC_VECTOR (127 downto 0); 
            counter : in  integer range 0 to 8;            
            RK_Row  : out STD_LOGIC_VECTOR (127 downto 0); 
            L_next  : out STD_LOGIC_VECTOR (127 downto 0) 
        );
    end component;

    component CLEFIA_8_DOUBLE_SWAP is
        Port ( input  : in  std_logic_vector (127 downto 0);
               output : out std_logic_vector (127 downto 0));
    end component;

    -- =========================================================
    -- SIGNALS
    -- =========================================================
    type state_type is (IDLE, GEN_L, SETUP, ROUNDS, FINISH);
    signal state : state_type;

    signal reg_data : std_logic_vector(127 downto 0);
    signal reg_key  : std_logic_vector(127 downto 0); 
    signal reg_L    : std_logic_vector(127 downto 0);
    signal rk_storage : rk_array;
    signal wk0, wk1, wk2, wk3 : std_logic_vector(31 downto 0); 

    signal ks_ctr    : integer range 0 to 12;
    signal round_ctr : integer range 0 to 18; 
    signal mode_dec  : std_logic;

    signal enc_exp_ctr      : integer range 0 to 9; 
    signal dec_exp_ctr      : integer range -1 to 9; 
    signal safe_enc_exp_idx : integer range 0 to 8;
    signal safe_dec_exp_idx : integer range 0 to 8;

    signal idx_L0, idx_L1     : integer range 0 to 59;
    signal l_gen_con0, l_gen_con1 : std_logic_vector(31 downto 0);
    signal enc_L_in_sig       : std_logic_vector(127 downto 0);
    signal enc_rk_row, enc_l_next : std_logic_vector(127 downto 0);
    signal dec_rk_row, dec_l_next : std_logic_vector(127 downto 0);
    
    signal bridge_in          : std_logic_vector(127 downto 0);
    signal l_sigma8_out       : std_logic_vector(127 downto 0);
    
    signal current_rk0, current_rk1 : std_logic_vector(31 downto 0);
    signal round_data_in_sig  : std_logic_vector(127 downto 0);
    signal round_rk0_sig      : std_logic_vector(31 downto 0);
    signal round_rk1_sig      : std_logic_vector(31 downto 0);
    signal round_mode_sig     : std_logic;
    signal round_out_shared   : std_logic_vector(127 downto 0);
     
begin

    wk0 <= reg_key(127 downto 96); wk1 <= reg_key(95 downto 64);
    wk2 <= reg_key(63 downto 32);  wk3 <= reg_key(31 downto 0);

    idx_L0 <= 2 * ks_ctr;
    idx_L1 <= 2 * ks_ctr + 1;

    U_CON_L0: CON_TABLE port map (index => idx_L0, con_val => l_gen_con0);
    U_CON_L1: CON_TABLE port map (index => idx_L1, con_val => l_gen_con1);

    safe_enc_exp_idx <= enc_exp_ctr when enc_exp_ctr < 9 else 0;
    enc_L_in_sig <= (reg_L(31 downto 0) & reg_L(127 downto 32)) when state = SETUP else reg_L;

    U_KEY_EXP_FWD: CLEFIA_Key_Row_Gen port map (
        L_curr  => enc_L_in_sig, K => reg_key, counter => safe_enc_exp_idx,
        RK_Row  => enc_rk_row, L_next => enc_l_next
    );

    safe_dec_exp_idx <= dec_exp_ctr when dec_exp_ctr >= 0 else 0;

    U_KEY_EXP_INV: CLEFIA_INV_RK_GEN port map (
        L_curr  => reg_L, K => reg_key, counter => safe_dec_exp_idx,
        RK_Row  => dec_rk_row, L_next => dec_l_next
    );

    bridge_in <= round_out_shared(31 downto 0) & round_out_shared(127 downto 32);
    U_SIGMA8: CLEFIA_8_DOUBLE_SWAP port map (input => bridge_in, output => l_sigma8_out);

    process(round_ctr, mode_dec, rk_storage)
    begin
        if mode_dec = '0' then 
            current_rk0 <= rk_storage(2 * round_ctr);
            current_rk1 <= rk_storage(2 * round_ctr + 1);
        else 
            current_rk0 <= rk_storage(2 * (17 - round_ctr));
            current_rk1 <= rk_storage(2 * (17 - round_ctr) + 1);
        end if;
    end process;

    round_data_in_sig <= reg_L when state = GEN_L else reg_data;
    round_rk0_sig     <= l_gen_con0 when state = GEN_L else current_rk0;
    round_rk1_sig     <= l_gen_con1 when state = GEN_L else current_rk1;
    round_mode_sig    <= '1' when state = GEN_L else not mode_dec;

    U_ROUND_SHARED: CLEFIA_ROUND port map (
        data_in => round_data_in_sig, rk0 => round_rk0_sig, rk1 => round_rk1_sig,
        mode => round_mode_sig, data_out => round_out_shared
    );

    process(clk, rst)
        variable t0, t1, t2, t3 : std_logic_vector(31 downto 0);
        variable pw0, pw1, pw2, pw3 : std_logic_vector(31 downto 0);
        variable idx_base : integer;
    begin
        if rst = '1' then
            state <= IDLE; done <= '0';
            ks_ctr <= 0; round_ctr <= 0; enc_exp_ctr <= 0; dec_exp_ctr <= 0;
            reg_data <= (others => '0'); reg_key <= (others => '0'); reg_L <= (others => '0');
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    done <= '0';
                    if start = '1' then
                        reg_key <= key_in; reg_data <= data_in; mode_dec <= is_decrypt;
                        reg_L <= key_in; ks_ctr <= 0; state <= GEN_L;
                    end if;

                when GEN_L =>
                    if ks_ctr = 11 then
                        ks_ctr <= 0; state <= SETUP; 
                        if is_decrypt = '1' then
                            reg_L <= l_sigma8_out; 
                            dec_exp_ctr <= 8; 
                        else
                            reg_L <= round_out_shared;
                            enc_exp_ctr <= 0;
                        end if;
                    else
                        reg_L <= round_out_shared;
                        ks_ctr <= ks_ctr + 1;
                    end if;

                when SETUP =>
                    t0 := reg_data(127 downto 96); t1 := reg_data(95 downto 64);
                    t2 := reg_data(63 downto 32);  t3 := reg_data(31 downto 0);
                    if mode_dec = '0' then 
                        t1 := t1 xor wk0; t3 := t3 xor wk1;
                         rk_storage(0) <= enc_rk_row(127 downto 96);
                        rk_storage(1) <= enc_rk_row(95 downto 64);
                        rk_storage(2) <= enc_rk_row(63 downto 32);
                        rk_storage(3) <= enc_rk_row(31 downto 0);
                        reg_L <= enc_l_next; enc_exp_ctr <= 1;
                    else 
                        t1 := t1 xor wk2; t3 := t3 xor wk3;
                        rk_storage(32) <= dec_rk_row(127 downto 96);
                        rk_storage(33) <= dec_rk_row(95 downto 64);
                        rk_storage(34) <= dec_rk_row(63 downto 32);
                        rk_storage(35) <= dec_rk_row(31 downto 0);
                        reg_L <= dec_l_next; dec_exp_ctr <= 7;
                    end if;
                    reg_data <= t0 & t1 & t2 & t3;
                    round_ctr <= 0; state <= ROUNDS;

                when ROUNDS =>
                    reg_data <= round_out_shared;
                    if mode_dec = '0' then
                        if enc_exp_ctr <= 8 then
                            idx_base := 4 * enc_exp_ctr;
                            rk_storage(idx_base)   <= enc_rk_row(127 downto 96);
                            rk_storage(idx_base+1) <= enc_rk_row(95 downto 64);
                            rk_storage(idx_base+2) <= enc_rk_row(63 downto 32);
                            rk_storage(idx_base+3) <= enc_rk_row(31 downto 0);
                            reg_L <= enc_l_next; enc_exp_ctr <= enc_exp_ctr + 1;
                        end if;
                    else
                        if dec_exp_ctr >= 0 then 
                            idx_base := 4 * dec_exp_ctr;
                            rk_storage(idx_base)   <= dec_rk_row(127 downto 96);
                            rk_storage(idx_base+1) <= dec_rk_row(95 downto 64);
                            rk_storage(idx_base+2) <= dec_rk_row(63 downto 32);
                            rk_storage(idx_base+3) <= dec_rk_row(31 downto 0);
                            reg_L <= dec_l_next; dec_exp_ctr <= dec_exp_ctr - 1;
                        end if;
                    end if;

                    if round_ctr = 17 then
                        state <= FINISH; done <= '1';
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
                    if start = '0' then done <= '0'; state <= IDLE; end if;
                when others => state <= IDLE;
            end case;
        end if;
    end process;
end Behavioral;