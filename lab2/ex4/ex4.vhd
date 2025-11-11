library ieee;
use ieee.std_logic_1164.all;


entity arithmetic_unit is
    generic (
        n : positive := 4
    );
    port (

        a   : in  std_logic_vector(n - 1 downto 0);
        b   : in  std_logic_vector(n - 1 downto 0);
        cin : in  std_logic;
        code : in  std_logic_vector(2 downto 0);


        y    : out std_logic_vector(n - 1 downto 0);
        cout : out std_logic;
        ovf  : out std_logic
    );
end entity arithmetic_unit;


architecture concurrent_impl of arithmetic_unit is


    signal op1, op2 : std_logic_vector(n - 1 downto 0);
    

    signal add_cin : std_logic;


    signal s : std_logic_vector(n - 1 downto 0);


    signal c : std_logic_vector(n downto 0);


    signal ovf_unsigned_add : std_logic;
    signal ovf_unsigned_sub : std_logic;
    signal ovf_signed     : std_logic;

begin


    with code(1 downto 0) select
        op1 <= a when "00", -- a+b
               a when "01", -- a-b
               b when "10", -- b-a
               a when "11", -- a+b+cin
               (others => 'X') when others; 


    with code(1 downto 0) select
        op2 <= b when "00",     -- a+b
               not b when "01", -- a-b
               not a when "10", -- b-a
               b when "11",     -- a+b+cin
               (others => 'X') when others;


    with code(1 downto 0) select
        add_cin <= '0' when "00", -- a+b
                     '1' when "01", -- a-b (a + not(b) + 1)
                     '1' when "10", -- b-a (b + not(a) + 1)
                     cin when "11", -- a+b+cin
                     'X' when others;


    c(0) <= add_cin;

 
    adder_generate_loop : for i in 0 to n - 1 generate

        s(i) <= op1(i) xor op2(i) xor c(i);
        
        c(i + 1) <= (op1(i) and op2(i)) or (op1(i) and c(i)) or (op2(i) and c(i));
    end generate adder_generate_loop;


    y <= s;


    cout <= c(n);

    ovf_unsigned_add <= c(n);

    ovf_unsigned_sub <= not c(n);

    ovf_signed <= c(n) xor c(n - 1);


    with code select
        ovf <= ovf_unsigned_add when "000", -- y=a+b (unsigned)
               ovf_unsigned_sub when "001", -- y=a-b (unsigned)
               ovf_unsigned_sub when "010", -- y=b-a (unsigned)
               ovf_unsigned_add when "011", -- y=a+b+cin (unsigned)
               ovf_signed       when "100", -- y=a+b (signed)
               ovf_signed       when "101", -- y=a-b (signed)
               ovf_signed       when "110", -- y=b-a (signed)
               ovf_signed       when "111", -- y=a+b+cin (signed)
               'X'              when others;

end architecture concurrent_impl;