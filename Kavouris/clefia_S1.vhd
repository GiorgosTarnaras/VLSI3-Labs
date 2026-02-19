library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CLEFIA_S1 is
    Port ( x : in  std_logic_vector (7 downto 0);
           y : out std_logic_vector (7 downto 0));
end CLEFIA_S1;

architecture behavioral of CLEFIA_S1 is
    type sbox_array is array (0 to 255) of std_logic_vector(7 downto 0);
    
    constant S1_TABLE : sbox_array := (
        x"6c", x"da", x"c3", x"e9", x"4e", x"9d", x"0a", x"3d", x"b8", x"36", x"b4", x"38", x"13", x"34", x"0c", x"d9",
        x"bf", x"74", x"94", x"8f", x"b7", x"9c", x"e5", x"dc", x"9e", x"07", x"49", x"4f", x"98", x"2c", x"b0", x"93",
        x"12", x"eb", x"cd", x"b3", x"92", x"e7", x"41", x"60", x"e3", x"21", x"27", x"3b", x"e6", x"19", x"d2", x"0e",
        x"91", x"11", x"c7", x"3f", x"2a", x"8e", x"a1", x"bc", x"2b", x"c8", x"c5", x"0f", x"5b", x"f3", x"87", x"8b",
        x"fb", x"f5", x"de", x"20", x"c6", x"a7", x"84", x"ce", x"d8", x"65", x"51", x"c9", x"a4", x"ef", x"43", x"53",
        x"25", x"5d", x"9b", x"31", x"e8", x"3e", x"0d", x"d7", x"80", x"ff", x"69", x"8a", x"ba", x"0b", x"73", x"5c",
        x"6e", x"54", x"15", x"62", x"f6", x"35", x"30", x"52", x"a3", x"16", x"d3", x"28", x"32", x"fa", x"aa", x"5e",
        x"cf", x"ea", x"ed", x"78", x"33", x"58", x"09", x"7b", x"63", x"c0", x"c1", x"46", x"1e", x"df", x"a9", x"99",
        x"55", x"04", x"c4", x"86", x"39", x"77", x"82", x"ec", x"40", x"18", x"90", x"97", x"59", x"dd", x"83", x"1f",
        x"9a", x"37", x"06", x"24", x"64", x"7c", x"a5", x"56", x"48", x"08", x"85", x"d0", x"61", x"26", x"ca", x"6f",
        x"7e", x"6a", x"b6", x"71", x"a0", x"70", x"05", x"d1", x"45", x"8c", x"23", x"1c", x"f0", x"ee", x"89", x"ad",
        x"7a", x"4b", x"c2", x"2f", x"db", x"5a", x"4d", x"76", x"67", x"17", x"2d", x"f4", x"cb", x"b1", x"4a", x"a8",
        x"b5", x"22", x"47", x"3a", x"d5", x"10", x"4c", x"72", x"cc", x"00", x"f9", x"e0", x"fd", x"e2", x"fe", x"ae",
        x"f8", x"5f", x"ab", x"f1", x"1b", x"42", x"81", x"d6", x"be", x"44", x"29", x"a6", x"57", x"b9", x"af", x"f2",
        x"d4", x"75", x"66", x"bb", x"68", x"9f", x"50", x"02", x"01", x"3c", x"7f", x"8d", x"1a", x"88", x"bd", x"ac",
        x"f7", x"e4", x"79", x"96", x"a2", x"fc", x"6d", x"b2", x"6b", x"03", x"e1", x"2e", x"7d", x"14", x"95", x"1d"
    );
begin
    y <= S1_TABLE(to_integer(unsigned(x)));
end behavioral;