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

    -- COMPONENT DECLARATIONS
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

    component CLEFIA_DOUBLE_SWAP is
        Port ( input  : in  std_logic_vector (127 downto 0);
               output : out std_logic_vector (127 downto 0));
    end component;

    -- SIGNALS

    -- FSM State
    type state_type is (IDLE, L_GEN, KEY_EXP, DATA_PROC, FINISH);
    signal state : state_type;


    type rk_array is array (0 to 35) of std_logic_vector(31 downto 0);
    
    -- Data Registers
    signal reg_data : std_logic_vector(127 downto 0);
    signal reg_key  : std_logic_vector(127 downto 0);
    signal mode_dec : std_logic; -- Latched mode
    signal round_ctr : integer range 0 to 18;

    -- Key Expansion Signals
    signal L, P : std_logic_vector(127 downto 0);
    signal WK_bus  : std_logic_vector(127 downto 0);
    signal RK_bus  : rk_array;
    
    -- Whitening Keys
    signal wk0, wk1, wk2, wk3 : std_logic_vector(31 downto 0);

    -- Round Logic Signals
    signal gfn_in     : std_logic_vector(127 downto 0);
    signal gfn_out_enc: std_logic_vector(127 downto 0);
    signal gfn_out_dec: std_logic_vector(127 downto 0);
    signal current_rk0  : std_logic_vector(31 downto 0);
    signal current_rk1  : std_logic_vector(31 downto 0);
    signal double_swap_in : std_logic_vector(127 downto 0);
    signal double_swap_out : std_logic_vector(127 downto 0);

begin

    
    U_ROUND_ENC: CLEFIA_ROUND port map (
        data_in  => gfn_in,
        rk0      => current_rk0,
        rk1      => current_rk1,
        data_out => gfn_out_enc
    );

    U_ROUND_DEC: CLEFIA_ROUND_INV port map (
        data_in  => gfn_in,
        rk0      => current_rk0,
        rk1      => current_rk1,
        data_out => gfn_out_dec
    );

    U_DOUBLE_SWAP: CLEFIA_DOUBLE_SWAP port map ( 
        input => double_swap_in,
        output => double_swap_out
    );

    process(state, round_ctr, mode_dec, RK_bus)
        variable idx_0 : integer;
        variable idx_1 : integer;
    begin

        case state is  
            when L_GEN =>
                -- During L generation, RKs are actually the first 24 CON values
                current_rk0 <= CON(round_ctr * 2);
                current_rk1 <= CON(round_ctr * 2 + 1);
                gfn_in <= L;
            when DATA_PROC => 
                if mode_dec = '0' then
                    idx_0 := 2 * round_ctr;
                    idx_1 := (2 * round_ctr) + 1;
                else
                    idx_0 := 2 * (17 - round_ctr);
                    idx_1 := (2 * (17 - round_ctr)) + 1;
                end if;
                current_rk0 <= RK_bus(idx_0);
                current_rk1 <= RK_bus(idx_1);
                gfn_in <= 
        end case;

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
