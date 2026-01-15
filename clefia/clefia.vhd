--------------------------------------------------------------------------------
-- CLEFIA 128-bit Block Cipher - Complete Correct Implementation
-- Full 128-bit key support with proper CON constants
-- Based on Sony Corporation specification (June 1, 2007)
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CLEFIA is
    generic (
        KEY_SIZE : integer := 128
    );
    port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        start        : in  std_logic;
        mode         : in  std_logic;  -- '0' encrypt, '1' decrypt
        plaintext    : in  std_logic_vector(127 downto 0);
        key          : in  std_logic_vector(127 downto 0);
        ciphertext   : out std_logic_vector(127 downto 0);
        done         : out std_logic;
        valid        : out std_logic
    );
end CLEFIA;

architecture rtl of CLEFIA is

    type sbox_2d is array (0 to 15, 0 to 15) of std_logic_vector(7 downto 0);
    type matrix_4x4 is array (0 to 3, 0 to 3) of std_logic_vector(7 downto 0);
    type state_type is (IDLE, KEY_GFN, KEY_EXPAND, INIT_WHITE, ROUNDS, FINAL_WHITE, OUTPUT);
    type rk_array is array (0 to 51) of std_logic_vector(31 downto 0);
    type con_array is array (0 to 59) of std_logic_vector(31 downto 0);
    
    signal state, next_state : state_type;
    signal T0, T1, T2, T3, T0_n, T1_n, T2_n, T3_n : std_logic_vector(31 downto 0);
    signal round_cnt : integer range 0 to 26;
    signal WK0, WK1, WK2, WK3 : std_logic_vector(31 downto 0);
    signal RK : rk_array;
    signal L : std_logic_vector(127 downto 0);
    signal ks_done : std_logic;
    signal gfn_cnt : integer range 0 to 13;
    signal exp_cnt : integer range 0 to 10;
    

    constant S0 : sbox_2d := (
        (x"57",x"49",x"d1",x"c6",x"2f",x"33",x"74",x"fb",x"95",x"6d",x"82",x"ea",x"0e",x"b0",x"a8",x"1c"),
        (x"28",x"d0",x"4b",x"92",x"5c",x"ee",x"85",x"b1",x"c4",x"0a",x"76",x"3d",x"63",x"f9",x"17",x"af"),
        (x"bf",x"a1",x"19",x"65",x"f7",x"7a",x"32",x"20",x"06",x"ce",x"e4",x"83",x"9d",x"5b",x"4c",x"d8"),
        (x"42",x"5d",x"2e",x"e8",x"d4",x"9b",x"0f",x"13",x"3c",x"89",x"67",x"c0",x"71",x"aa",x"b6",x"f5"),
        (x"a4",x"be",x"fd",x"8c",x"12",x"00",x"97",x"da",x"78",x"e1",x"cf",x"6b",x"39",x"43",x"55",x"26"),
        (x"30",x"98",x"cc",x"dd",x"eb",x"54",x"b3",x"8f",x"4e",x"16",x"fa",x"22",x"a5",x"77",x"09",x"61"),
        (x"d6",x"2a",x"53",x"37",x"45",x"c1",x"6c",x"ae",x"ef",x"70",x"08",x"99",x"8b",x"1d",x"f2",x"b4"),
        (x"e9",x"c7",x"9f",x"4a",x"31",x"25",x"fe",x"7c",x"d3",x"a2",x"bd",x"56",x"14",x"88",x"60",x"0b"),
        (x"cd",x"e2",x"34",x"50",x"9e",x"dc",x"11",x"05",x"2b",x"b7",x"a9",x"48",x"ff",x"66",x"8a",x"73"),
        (x"03",x"75",x"86",x"f1",x"6a",x"a7",x"40",x"c2",x"b9",x"2c",x"db",x"1f",x"58",x"94",x"3e",x"ed"),
        (x"fc",x"1b",x"a0",x"04",x"b8",x"8d",x"e6",x"59",x"62",x"93",x"35",x"7e",x"ca",x"21",x"df",x"47"),
        (x"15",x"f3",x"ba",x"7f",x"a6",x"69",x"c8",x"4d",x"87",x"3b",x"9c",x"01",x"e0",x"de",x"24",x"52"),
        (x"7b",x"0c",x"68",x"1e",x"80",x"b2",x"5a",x"e7",x"ad",x"d5",x"23",x"f4",x"46",x"3f",x"91",x"c9"),
        (x"6e",x"84",x"72",x"bb",x"0d",x"18",x"d9",x"96",x"f0",x"5f",x"41",x"ac",x"27",x"c5",x"e3",x"3a"),
        (x"81",x"6f",x"07",x"a3",x"79",x"f6",x"2d",x"38",x"1a",x"44",x"5e",x"b5",x"d2",x"ec",x"cb",x"90"),
        (x"9a",x"36",x"e5",x"29",x"c3",x"4f",x"ab",x"64",x"51",x"f8",x"10",x"d7",x"bc",x"02",x"7d",x"8e")
    );
    
    constant S1 : sbox_2d := (
        (x"6c",x"da",x"c3",x"e9",x"4e",x"9d",x"0a",x"3d",x"b8",x"36",x"b4",x"38",x"13",x"34",x"0c",x"d9"),
        (x"bf",x"74",x"94",x"8f",x"b7",x"9c",x"e5",x"dc",x"9e",x"07",x"49",x"4f",x"98",x"2c",x"b0",x"93"),
        (x"12",x"eb",x"cd",x"b3",x"92",x"e7",x"41",x"60",x"e3",x"21",x"27",x"3b",x"e6",x"19",x"d2",x"0e"),
        (x"91",x"11",x"c7",x"3f",x"2a",x"8e",x"a1",x"bc",x"2b",x"c8",x"c5",x"0f",x"5b",x"f3",x"87",x"8b"),
        (x"fb",x"f5",x"de",x"20",x"c6",x"a7",x"84",x"ce",x"d8",x"65",x"51",x"c9",x"a4",x"ef",x"43",x"53"),
        (x"25",x"5d",x"9b",x"31",x"e8",x"3e",x"0d",x"d7",x"80",x"ff",x"69",x"8a",x"ba",x"0b",x"73",x"5c"),
        (x"6e",x"54",x"15",x"62",x"f6",x"35",x"30",x"52",x"a3",x"16",x"d3",x"28",x"32",x"fa",x"aa",x"5e"),
        (x"cf",x"ea",x"ed",x"78",x"33",x"58",x"09",x"7b",x"63",x"c0",x"c1",x"46",x"1e",x"df",x"a9",x"99"),
        (x"55",x"04",x"c4",x"86",x"39",x"77",x"82",x"ec",x"40",x"18",x"90",x"97",x"59",x"dd",x"83",x"1f"),
        (x"9a",x"37",x"06",x"24",x"64",x"7c",x"a5",x"56",x"48",x"08",x"85",x"d0",x"61",x"26",x"ca",x"6f"),
        (x"7e",x"6a",x"b6",x"71",x"a0",x"70",x"05",x"d1",x"45",x"8c",x"23",x"1c",x"f0",x"ee",x"89",x"ad"),
        (x"7a",x"4b",x"c2",x"2f",x"db",x"5a",x"4d",x"76",x"67",x"17",x"2d",x"f4",x"cb",x"b1",x"4a",x"a8"),
        (x"b5",x"22",x"47",x"3a",x"d5",x"10",x"4c",x"72",x"cc",x"00",x"f9",x"e0",x"fd",x"e2",x"fe",x"ae"),
        (x"f8",x"5f",x"ab",x"f1",x"1b",x"42",x"81",x"d6",x"be",x"44",x"29",x"a6",x"57",x"b9",x"af",x"f2"),
        (x"d4",x"75",x"66",x"bb",x"68",x"9f",x"50",x"02",x"01",x"3c",x"7f",x"8d",x"1a",x"88",x"bd",x"ac"),
        (x"f7",x"e4",x"79",x"96",x"a2",x"fc",x"6d",x"b2",x"6b",x"03",x"e1",x"2e",x"7d",x"14",x"95",x"1d")
    );
    
    constant M0 : matrix_4x4 := (
        (x"01",x"02",x"04",x"06"),(x"02",x"01",x"06",x"04"),
        (x"04",x"06",x"01",x"02"),(x"06",x"04",x"02",x"01")
    );
    
    constant M1 : matrix_4x4 := (
        (x"01",x"08",x"02",x"0a"),(x"08",x"01",x"0a",x"02"),
        (x"02",x"0a",x"01",x"08"),(x"0a",x"02",x"08",x"01")
    );

    constant CON_128 : con_array := (
        x"f56b7aeb", x"994a8a42", x"96a4bd75", x"fa854521",
        x"735b768a", x"1f7abac4", x"d5bc3b45", x"b99d5d62",
        x"52d73592", x"3ef636e5", x"c57a1ac9", x"a95b9b72",
        x"5ab42554", x"369555ed", x"1553ba9a", x"7972b2a2",
        x"e6b85d4d", x"8a995951", x"4b550696", x"2774b4fc",
        x"c9bb034b", x"a59a5a7e", x"88cc81a5", x"e4ed2d3f",
        x"7c6f68e2", x"104e8ecb", x"d2263471", x"be07c765",
        x"511a3208", x"3d3bfbe6", x"1084b134", x"7ca565a7",
        x"304bf0aa", x"5c6aaa87", x"f4347855", x"9815d543",
        x"4213141a", x"2e32f2f5", x"cd180a0d", x"a139f97a",
        x"5e852d36", x"32a464e9", x"c353169b", x"af72b274",
        x"8db88b4d", x"e199593a", x"7ed56d96", x"12f434c9",
        x"d37b36cb", x"bf5a9a64", x"85ac9b65", x"e98d4d32",
        x"7adf6582", x"16fe3ecd", x"d17e32c1", x"bd5f9f66",
        x"50b63150", x"3c9757e7", x"1052b098", x"7c73b3a7"
    );
    
    -- Functions
    function gf_mult(a, b : std_logic_vector(7 downto 0)) return std_logic_vector is
        variable r, ta : std_logic_vector(7 downto 0);
        variable tb : std_logic_vector(7 downto 0);
    begin
        r := x"00"; ta := a; tb := b;
        for i in 0 to 7 loop
            if tb(0) = '1' then r := r xor ta; end if;
            if ta(7) = '1' then ta := (ta(6 downto 0) & '0') xor x"1D";
            else ta := ta(6 downto 0) & '0'; end if;
            tb := '0' & tb(7 downto 1);
        end loop;
        return r;
    end function;

    function mat_mult(M : matrix_4x4; v : std_logic_vector(31 downto 0)) return std_logic_vector is
        variable r : std_logic_vector(31 downto 0);
        variable v0, v1, v2, v3, t : std_logic_vector(7 downto 0);
    begin
        v0 := v(31 downto 24); v1 := v(23 downto 16); 
        v2 := v(15 downto 8); v3 := v(7 downto 0);
        for i in 0 to 3 loop
            t := gf_mult(M(i,0),v0) xor gf_mult(M(i,1),v1) xor 
                 gf_mult(M(i,2),v2) xor gf_mult(M(i,3),v3);
            r((3-i)*8+7 downto (3-i)*8) := t;
        end loop;
        return r;
    end function;

    function F0(RK, x : std_logic_vector(31 downto 0)) return std_logic_vector is
        variable T : std_logic_vector(31 downto 0);
        variable T0, T1, T2, T3 : std_logic_vector(7 downto 0);
        variable r, c : integer range 0 to 15;
    begin
        T := RK xor x;
        T0 := T(31 downto 24); T1 := T(23 downto 16);
        T2 := T(15 downto 8); T3 := T(7 downto 0);
        
        r := to_integer(unsigned(T0(7 downto 4)));
        c := to_integer(unsigned(T0(3 downto 0)));
        T0 := S0(r,c);
        r := to_integer(unsigned(T1(7 downto 4)));
        c := to_integer(unsigned(T1(3 downto 0)));
        T1 := S1(r,c);
        r := to_integer(unsigned(T2(7 downto 4)));
        c := to_integer(unsigned(T2(3 downto 0)));
        T2 := S0(r,c);
        r := to_integer(unsigned(T3(7 downto 4)));
        c := to_integer(unsigned(T3(3 downto 0)));
        T3 := S1(r,c);
        
        return mat_mult(M0, T0 & T1 & T2 & T3);
    end function;

    function F1(RK, x : std_logic_vector(31 downto 0)) return std_logic_vector is
        variable T : std_logic_vector(31 downto 0);
        variable T0, T1, T2, T3 : std_logic_vector(7 downto 0);
        variable r, c : integer range 0 to 15;
    begin
        T := RK xor x;
        T0 := T(31 downto 24); T1 := T(23 downto 16);
        T2 := T(15 downto 8); T3 := T(7 downto 0);
        
        r := to_integer(unsigned(T0(7 downto 4)));
        c := to_integer(unsigned(T0(3 downto 0)));
        T0 := S1(r,c);
        r := to_integer(unsigned(T1(7 downto 4)));
        c := to_integer(unsigned(T1(3 downto 0)));
        T1 := S0(r,c);
        r := to_integer(unsigned(T2(7 downto 4)));
        c := to_integer(unsigned(T2(3 downto 0)));
        T2 := S1(r,c);
        r := to_integer(unsigned(T3(7 downto 4)));
        c := to_integer(unsigned(T3(3 downto 0)));
        T3 := S0(r,c);
        
        return mat_mult(M1, T0 & T1 & T2 & T3);
    end function;
    
    function dswap(x : std_logic_vector(127 downto 0)) return std_logic_vector is
    begin
        return x(120 downto 64) & x(6 downto 0) & x(127 downto 121) & x(63 downto 7);
    end function;

begin

    -- State register
    process(clk, rst)
    begin
        if rst = '1' then
            state <= IDLE;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    -- Next state logic
    process(state, start, ks_done, round_cnt, gfn_cnt)
    begin
        next_state <= state;
        case state is
            when IDLE => 
                if start = '1' then next_state <= KEY_GFN; end if;
            when KEY_GFN => 
                if gfn_cnt >= 12 then next_state <= KEY_EXPAND; end if;
            when KEY_EXPAND => 
                if ks_done = '1' then next_state <= INIT_WHITE; end if;
            when INIT_WHITE => 
                next_state <= ROUNDS;
            when ROUNDS => 
                if round_cnt >= 17 then next_state <= FINAL_WHITE; end if;
            when FINAL_WHITE => 
                next_state <= OUTPUT;
            when OUTPUT => 
                next_state <= IDLE;
        end case;
    end process;

    -- Counters
    process(clk, rst)
    begin
        if rst = '1' then
            round_cnt <= 0;
            gfn_cnt <= 0;
            exp_cnt <= 0;
        elsif rising_edge(clk) then
            if state = INIT_WHITE then
                round_cnt <= 0;
            elsif state = ROUNDS then
                round_cnt <= round_cnt + 1;
            end if;
            
            if state = KEY_GFN then
                gfn_cnt <= gfn_cnt + 1;
            else
                gfn_cnt <= 0;
            end if;
            
            if state = KEY_EXPAND then
                exp_cnt <= exp_cnt + 1;
            else
                exp_cnt <= 0;
            end if;
        end if;
    end process;

    -- Data registers
    process(clk, rst)
    begin
        if rst = '1' then
            T0 <= (others => '0'); T1 <= (others => '0');
            T2 <= (others => '0'); T3 <= (others => '0');
        elsif rising_edge(clk) then
            T0 <= T0_n; T1 <= T1_n; T2 <= T2_n; T3 <= T3_n;
        end if;
    end process;

    -- Datapath
    process(state, plaintext, T0, T1, T2, T3, WK0, WK1, WK2, WK3, RK, round_cnt, mode)
        variable F0o, F1o : std_logic_vector(31 downto 0);
        variable v_T0, v_T1, v_T2, v_T3 : std_logic_vector(31 downto 0);
        variable rki : integer;
    begin
        -- Default hold
        T0_n <= T0; T1_n <= T1; T2_n <= T2; T3_n <= T3;
        
        case state is
            when INIT_WHITE =>
                if mode = '0' then  -- Encrypt (Direct Map)
                    T0_n <= plaintext(127 downto 96);
                    T1_n <= plaintext(95 downto 64) xor WK0;
                    T2_n <= plaintext(63 downto 32);
                    T3_n <= plaintext(31 downto 0) xor WK1;
                else  -- Decrypt (FIXED: Reverse of Final White)
                    -- Maps C0->T3, C1->T0, C2->T1, C3->T2 (Inverse of Enc Final Swap)
                    T0_n <= plaintext(95 downto 64) xor WK2; -- Input was C1, becomes T0
                    T1_n <= plaintext(63 downto 32);         -- Input was C2, becomes T1
                    T2_n <= plaintext(31 downto 0) xor WK3;  -- Input was C3, becomes T2
                    T3_n <= plaintext(127 downto 96);        -- Input was C0, becomes T3
                end if;
                
            when ROUNDS =>
                v_T0 := T0; v_T1 := T1; v_T2 := T2; v_T3 := T3;

                if mode = '0' then  -- ENCRYPTION
                    F0o := F0(RK(round_cnt*2), v_T0);
                    F1o := F1(RK(round_cnt*2+1), v_T2);
                    v_T1 := v_T1 xor F0o;
                    v_T3 := v_T3 xor F1o;
                    -- Left Rotate
                    T0_n <= v_T1; T1_n <= v_T2; T2_n <= v_T3; T3_n <= v_T0;
                    
                else  -- DECRYPTION
                    -- Right Rotate (Inverse)
                    v_T0 := T3; -- Pre-rot T0
                    v_T1 := T0; -- Pre-rot T1
                    v_T2 := T1; -- Pre-rot T2
                    v_T3 := T2; -- Pre-rot T3
                    
                    rki := (18 - 1 - round_cnt) * 2;
                    F0o := F0(RK(rki), v_T0);
                    F1o := F1(RK(rki+1), v_T2);
                    
                    v_T1 := v_T1 xor F0o;
                    v_T3 := v_T3 xor F1o;
                    
                    T0_n <= v_T0; T1_n <= v_T1; T2_n <= v_T2; T3_n <= v_T3;
                end if;
                
            when FINAL_WHITE =>
                if mode = '0' then -- Encrypt (With Swap)
                    T0_n <= T3;              -- C0 = T3
                    T1_n <= T0 xor WK2;      -- C1 = T0 ^ WK2
                    T2_n <= T1;              -- C2 = T1
                    T3_n <= T2 xor WK3;      -- C3 = T2 ^ WK3
                else -- Decrypt (FIXED: Direct Map to reverse Enc Init)
                    T0_n <= T0;              -- P0 = T0
                    T1_n <= T1 xor WK0;      -- P1 = T1 ^ WK0
                    T2_n <= T2;              -- P2 = T2
                    T3_n <= T3 xor WK1;      -- P3 = T3 ^ WK1
                end if;

            when others =>
                null;
        end case;
    end process;

    -- Key schedule (Unchanged)
    process(clk, rst)
        variable L0, L1, L2, L3 : std_logic_vector(31 downto 0);
        variable F0o, F1o : std_logic_vector(31 downto 0);
    begin
        if rst = '1' then
            ks_done <= '0';
            L <= (others => '0');
            WK0 <= (others => '0'); WK1 <= (others => '0');
            WK2 <= (others => '0'); WK3 <= (others => '0');
            -- Initialize RK to zeros to avoid latches if not written
            RK <= (others => (others => '0'));
            
        elsif rising_edge(clk) then
            ks_done <= '0';
            
            if state = KEY_GFN then
                if gfn_cnt = 0 then
                    L <= key;
                else
                    L0 := L(127 downto 96); L1 := L(95 downto 64);
                    L2 := L(63 downto 32);  L3 := L(31 downto 0);
                    F0o := F0(CON_128((gfn_cnt-1)*2), L0);
                    F1o := F1(CON_128((gfn_cnt-1)*2+1), L2);
                    L <= (L1 xor F0o) & L2 & (L3 xor F1o) & L0; 
                end if;
                
            elsif state = KEY_EXPAND then
                if exp_cnt = 0 then
                    WK0 <= key(127 downto 96); WK1 <= key(95 downto 64);
                    WK2 <= key(63 downto 32);  WK3 <= key(31 downto 0);
                    -- Final Rotation fix for L coming out of GFN
                    L <= L(31 downto 0) & L(127 downto 96) & L(95 downto 64) & L(63 downto 32);
                elsif exp_cnt <= 9 then
                    L0 := L(127 downto 96) xor CON_128(24 + (exp_cnt-1)*4);
                    L1 := L(95 downto 64)  xor CON_128(24 + (exp_cnt-1)*4 + 1);
                    L2 := L(63 downto 32)  xor CON_128(24 + (exp_cnt-1)*4 + 2);
                    L3 := L(31 downto 0)   xor CON_128(24 + (exp_cnt-1)*4 + 3);
                    
                    L <= dswap(L); 
                    
                    if (exp_cnt-1) mod 2 = 1 then
                        L0 := L0 xor key(127 downto 96);
                        L1 := L1 xor key(95 downto 64);
                        L2 := L2 xor key(63 downto 32);
                        L3 := L3 xor key(31 downto 0);
                    end if;
                    
                    RK((exp_cnt-1)*4)   <= L0;
                    RK((exp_cnt-1)*4+1) <= L1;
                    RK((exp_cnt-1)*4+2) <= L2;
                    RK((exp_cnt-1)*4+3) <= L3;
                else
                    ks_done <= '1';
                end if;
            end if;
        end if;
    end process;
    
    -- Output
    process(state, T0, T1, T2, T3)
    begin
        if state = OUTPUT then
            ciphertext <= T0 & T1 & T2 & T3;
            done <= '1';
            valid <= '1';
        else
            ciphertext <= (others => '0');
            done <= '0';
            valid <= '0';
        end if;
    end process;

end rtl;
