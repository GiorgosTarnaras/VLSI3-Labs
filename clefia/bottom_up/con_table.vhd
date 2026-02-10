library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CON_TABLE is
    Port ( index  : in  integer range 0 to 59;
           con_val: out std_logic_vector (31 downto 0));
end CON_TABLE;

architecture behavioral of CON_TABLE is
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
begin
    con_val <= CON(index);
end behavioral;