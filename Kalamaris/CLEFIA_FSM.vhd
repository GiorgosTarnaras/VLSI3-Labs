library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CLEFIA_128_FSM is
    Port ( 
        clk        : in  std_logic;
        rst        : in  std_logic;
        start      : in  std_logic;
        key        : in  std_logic_vector (127 downto 0);
        plaintext  : in  std_logic_vector (127 downto 0);
        ciphertext : out std_logic_vector (127 downto 0);
        finished: out std_logic
    );
end CLEFIA_128_FSM;

architecture fsm of CLEFIA_128_FSM is

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

    component CLEFIA_GFN_ROUND is
        Port ( 
            data_in  : in  std_logic_vector (127 downto 0); 
            rk0      : in  std_logic_vector (31 downto 0);  
            rk1      : in  std_logic_vector (31 downto 0);  
            data_out : out std_logic_vector (127 downto 0)  
        );
    end component;

    component CLEFIA_RK_GEN is
        Port ( 
            L_in : in  std_logic_vector (127 downto 0); 
            K : in  std_logic_vector (127 downto 0); 
            CON: in std_logic_vector(127 downto 0);
            odd : in  std_logic;              
            RK_row : out std_logic_vector (127 downto 0); 
            L_swapped : out std_logic_vector (127 downto 0) 
        );
    end component;

    type state_type is (IDLE, LOAD1, L_GEN, LOAD2, KEY_EPXAND, ENCRYPTION, DONE);
    signal current_state, next_state : state_type;
    
    signal gfn_data_in_reg : std_logic_vector(127 downto 0); 
    signal gfn_rk0_reg, gfn_rk1_reg : std_logic_vector(31 downto 0);
    signal L_reg : std_logic_vector(127 downto 0); 
    
    signal CON_wire : std_logic_vector(127 downto 0); 
    signal odd_wire : std_logic;
    signal wk0, wk1, wk2, wk3 : std_logic_vector(31 downto 0); 
    signal gfn_data_out, RK_row, L_swapped : std_logic_vector(127 downto 0);
    signal counter, rk_counter: integer range 0 to 18; 

begin

    GFN: CLEFIA_GFN_ROUND port map (
        data_in  => gfn_data_in_reg,        
        rk0      => gfn_rk0_reg,  
        rk1      => gfn_rk1_reg,  
        data_out => gfn_data_out    
    );

    U_KEY_EXP_ROW: CLEFIA_RK_GEN port map (
        L_in      => L_reg,
        K         => key,
        CON       => CON_wire,
        odd       => odd_wire, 
        RK_row    => RK_row,
        L_swapped => L_swapped
    );

    STATE_REG: process(clk, rst)
    begin
        if rst = '1' then
            current_state <= IDLE; 
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process STATE_REG;
    
    STATES: process(current_state, start, counter)
    begin        
        case current_state is    
            when IDLE =>            
                if start = '1' then next_state <= LOAD1;
                else next_state <= IDLE;
                end if;
            when LOAD1 =>
                next_state <= L_GEN;
            when L_GEN =>
                if counter = 11 then 
                    next_state <= KEY_EPXAND;
                else 
                    next_state <= L_GEN;
                end if;
            when KEY_EPXAND =>
                next_state <= LOAD2;
            when LOAD2 =>
                next_state <= ENCRYPTION;
            when ENCRYPTION =>
                if counter = 17 then 
                    next_state <= DONE;
                else 
                    next_state <= ENCRYPTION;
                end if;
            when DONE =>
                next_state <= IDLE;
        end case;
    end process STATES;

    TIMERS: process(clk)
    begin 
        if rising_edge(clk) then        
            case current_state is 
                when L_GEN =>
                    if counter < 11 then
                        counter <= counter + 1;
                    end if;
                when ENCRYPTION =>
                    if counter < 17 then 
                        counter <= counter + 1;
                        if counter mod 2 = 0  then 
                            rk_counter <= rk_counter + 1;
                        end if;
                    end if;
                when others => 
                    counter <= 1;
                    rk_counter <= 1;
            end case;
        end if;
    end process TIMERS;

    UNIT_REGS: process(clk)
    begin 
        if rising_edge(clk) then 

            case current_state is
                when IDLE =>
                    ciphertext <= (others => '0');
                    finished <= '0';
                when LOAD1 =>
                    wk0 <= key(127 downto 96);
                    wk1 <= key(95 downto 64);
                    wk2 <= key(63 downto 32);
                    wk3 <= key(31 downto 0);
                    gfn_data_in_reg <= key;
                    gfn_rk0_reg <= CON(0);
                    gfn_rk1_reg <= CON(1);
                when L_GEN => 
                    gfn_data_in_reg <= gfn_data_out;
                    gfn_rk0_reg <= CON(2 * counter);
                    gfn_rk1_reg <= CON(2 * counter + 1);  

                when KEY_EPXAND =>
                    L_reg <= gfn_data_out(31 downto 0) & gfn_data_out(127 downto 32);
                    CON_wire <= CON(24)&CON(25)&CON(26)&CON(27);
                    odd_wire <= '0';

                when LOAD2 =>
                   gfn_data_in_reg <= plaintext(127 downto 96) & (plaintext(95 downto 64) xor wk0) & plaintext(63 downto 32) & (plaintext(31 downto 0) xor wk1);
                   gfn_rk0_reg <= RK_row(127 downto 96);
                   gfn_rk1_reg <= RK_row(95 downto 64);

                when ENCRYPTION =>
                    gfn_data_in_reg <= gfn_data_out;
                    if (counter mod 2) = 1 then 
                        gfn_rk0_reg <= RK_row(63 downto 32);
                        gfn_rk1_reg <= RK_row(31 downto 0);
                        if counter < 17 then
                            CON_wire <= CON(24 + 4*rk_counter)&CON(25 + 4*rk_counter)&CON(26 + 4*rk_counter)&CON(27 + 4*rk_counter);
                            odd_wire <= not (odd_wire); 
                            L_reg <= L_swapped;
                        end if;
                    else 
                        gfn_rk0_reg <= RK_row(127 downto 96);
                        gfn_rk1_reg <= RK_row(95 downto 64);
                    end if;
                when DONE =>
                    ciphertext <= gfn_data_out(31 downto 0) & (gfn_data_out(127 downto 96) xor wk2) & gfn_data_out(95 downto 64) & (gfn_data_out(63 downto 32) xor wk3);
                    finished <= '1';

            end case;
        end if;
    end process UNIT_REGS;

end fsm;