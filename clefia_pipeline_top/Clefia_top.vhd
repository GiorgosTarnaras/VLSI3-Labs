library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CLEFIA_PIPELINED is
    Port ( 
        clk        : in  std_logic;
        key_in     : in  std_logic_vector (127 downto 0);
        data_in    : in  std_logic_vector (127 downto 0);
        data_out   : out std_logic_vector (127 downto 0)
    );
end CLEFIA_PIPELINED;

architecture structural of CLEFIA_PIPELINED is

    component CLEFIA_ROUND is
        Port ( 
            data_in  : in  std_logic_vector (127 downto 0); 
            rk0      : in  std_logic_vector (31 downto 0);  
            rk1      : in  std_logic_vector (31 downto 0);  
            data_out : out std_logic_vector (127 downto 0)  
        );
    end component;
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

    component CLEFIA_Key_Row_Gen is
    Port ( 
        L_curr  : in  STD_LOGIC_VECTOR (127 downto 0); -- Current value of L
        K       : in  STD_LOGIC_VECTOR (127 downto 0); -- Master Key K
        counter : in  integer range 0 to 8;            -- Loop index 'i' from algorithm
        RK_Row  : out STD_LOGIC_VECTOR (127 downto 0); -- Output RK for this row (e.g. RK0-3)
        L_next  : out STD_LOGIC_VECTOR (127 downto 0)  -- Sigma(L) for the next round
    );
    end component;

    type array_12_128 is array (0 to 12) of std_logic_vector(127 downto 0); -- L: intermediate key
    type array_9_128 is array (0 to 9) of std_logic_vector(127 downto 0); -- Round keys
    type array_18_128 is array (0 to 18) of std_logic_vector(127 downto 0); -- ciphertext
    type array_18_64 is array (0 to 18) of std_logic_vector(63 downto 0); -- rk

    signal L1, L1_REGS: array_12_128 := (others => (others => '0')); 
    signal RK, L2, L2_REGS: array_9_128 := (others => (others => '0'));
    signal CT, CT_REGS: array_18_128 := (others => (others => '0'));
    signal RK2i: array_18_64 := (others => (others => '0'));
begin

    GEN_L: for i in 0 to 11 generate 
        U1: CLEFIA_ROUND port map(data_in => L1_REGS(i), rk0 => CON(2*i), rk1 => CON(2*i+1), data_out => L1(i));
    end generate GEN_L;
    GEN_RK: for i in 0 to 8 generate 
        U2: CLEFIA_Key_Row_Gen port map(L_curr  => L2_REGS(i),
                                        K       => key_in,
                                        counter => i,
                                        RK_Row  => RK(i),
                                        L_next  => L2(i));
    end generate GEN_RK;
    GEN_CT: for i in 0 to 17 generate
        U3: CLEFIA_ROUND port map(
            data_in  => CT_REGS(i), 
            rk0      => RK2i(i)(63 downto 32), -- Example RK slicing, adjust to your RK_Row Gen
            rk1      => RK2i(i)(31 downto 0), 
            data_out => CT(i)
        );
    end generate GEN_CT;
    -- generate l with 12 stages pipelined with regs
    P1: process(clk)
        begin
            if rising_edge(clk) then
                L1_REGS(0) <= key_in;
                for i in 0 to 10 loop 
                    L1_REGS(i+1)<=L1(i);
                end loop;
            end if;
        end process P1;
    P2: process(clk)
        begin
            if rising_edge(clk) then
                L2_REGS(0) <= (L1(11)(31 downto 0) & L1(11)(127 downto 32));
                for i in 0 to 8 loop
                    L2_REGS(i+1) <= L2(i);
                    RK2i(2*i) <= RK(i)(127 downto 64);
                    RK2i(2*i+1) <= RK(i)(63 downto 0);
                end loop;
            end if;
        end process P2;

    P3: process(clk)
    begin
        if rising_edge(clk) then
            CT_REGS(0)  <= (data_in(127 downto 96 ) & (data_in(95 downto 64) xor key_in(127 downto 96)) & data_in(63 downto 32) & (data_in(31 downto 0) xor key_in(95 downto 64)));     -- Initial input
            for i in 0 to 16 loop
                CT_REGS(i+1) <= CT(i);
            end loop;
            CT_REGS(18) <= CT(17)(31 downto 0) & (CT(17)(127 downto 96) xor key_in(63 downto 32)) & CT(17)(95 downto 64) & (CT(17)(63 downto 32) xor key_in (31 downto 0));
        end if;
    end process P3;

    data_out <= CT_REGS(18); -- Final output from the last register

end structural;
 -- key ffeeddccbbaa99887766554433221100
 -- text 000102030405060708090a0b0c0d0e0f
 --cipher de2bf2fd9b74aacdf1298555459494fd
