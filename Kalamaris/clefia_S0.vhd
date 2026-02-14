library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CLEFIA_S0 is
    Port ( x : in  std_logic_vector (7 downto 0);
           y : out std_logic_vector (7 downto 0));
end CLEFIA_S0;

architecture behavioral of CLEFIA_S0 is
    type sbox_array is array (0 to 255) of std_logic_vector(7 downto 0);
    
    constant S0_TABLE : sbox_array := (
        x"57", x"49", x"d1", x"c6", x"2f", x"33", x"74", x"fb", x"95", x"6d", x"82", x"ea", x"0e", x"b0", x"a8", x"1c",
        x"28", x"d0", x"4b", x"92", x"5c", x"ee", x"85", x"b1", x"c4", x"0a", x"76", x"3d", x"63", x"f9", x"17", x"af",
        x"bf", x"a1", x"19", x"65", x"f7", x"7a", x"32", x"20", x"06", x"ce", x"e4", x"83", x"9d", x"5b", x"4c", x"d8",
        x"42", x"5d", x"2e", x"e8", x"d4", x"9b", x"0f", x"13", x"3c", x"89", x"67", x"c0", x"71", x"aa", x"b6", x"f5",
        x"a4", x"be", x"fd", x"8c", x"12", x"00", x"97", x"da", x"78", x"e1", x"cf", x"6b", x"39", x"43", x"55", x"26",
        x"30", x"98", x"cc", x"dd", x"eb", x"54", x"b3", x"8f", x"4e", x"16", x"fa", x"22", x"a5", x"77", x"09", x"61",
        x"d6", x"2a", x"53", x"37", x"45", x"c1", x"6c", x"ae", x"ef", x"70", x"08", x"99", x"8b", x"1d", x"f2", x"b4",
        x"e9", x"c7", x"9f", x"4a", x"31", x"25", x"fe", x"7c", x"d3", x"a2", x"bd", x"56", x"14", x"88", x"60", x"0b",
        x"cd", x"e2", x"34", x"50", x"9e", x"dc", x"11", x"05", x"2b", x"b7", x"a9", x"48", x"ff", x"66", x"8a", x"73",
        x"03", x"75", x"86", x"f1", x"6a", x"a7", x"40", x"c2", x"b9", x"2c", x"db", x"1f", x"58", x"94", x"3e", x"ed",
        x"fc", x"1b", x"a0", x"04", x"b8", x"8d", x"e6", x"59", x"62", x"93", x"35", x"7e", x"ca", x"21", x"df", x"47",
        x"15", x"f3", x"ba", x"7f", x"a6", x"69", x"c8", x"4d", x"87", x"3b", x"9c", x"01", x"e0", x"de", x"24", x"52",
        x"7b", x"0c", x"68", x"1e", x"80", x"b2", x"5a", x"e7", x"ad", x"d5", x"23", x"f4", x"46", x"3f", x"91", x"c9",
        x"6e", x"84", x"72", x"bb", x"0d", x"18", x"d9", x"96", x"f0", x"5f", x"41", x"ac", x"27", x"c5", x"e3", x"3a",
        x"81", x"6f", x"07", x"a3", x"79", x"f6", x"2d", x"38", x"1a", x"44", x"5e", x"b5", x"d2", x"ec", x"cb", x"90",
        x"9a", x"36", x"e5", x"29", x"c3", x"4f", x"ab", x"64", x"51", x"f8", x"10", x"d7", x"bc", x"02", x"7d", x"8e"
    );
begin
    y <= S0_TABLE(to_integer(unsigned(x)));
end behavioral;