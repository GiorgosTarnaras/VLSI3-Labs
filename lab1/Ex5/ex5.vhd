library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;    


entity binary_to_bcd_12bit is
    port (
        BIN_IN  : in  std_logic_vector(11 downto 0); 
        BCD_OUT : out std_logic_vector(15 downto 0)
    );
end entity binary_to_bcd_12bit;

architecture arch5 of binary_to_bcd_12bit is

    signal bin_int : integer range 0 to 4095;

    signal r_1000 : integer range 0 to 999; 
    signal r_100  : integer range 0 to 99;  

    signal d3_thousands : integer range 0 to 9;
    signal d2_hundreds  : integer range 0 to 9;
    signal d1_tens      : integer range 0 to 9;
    signal d0_units     : integer range 0 to 9;

begin 

    bin_int <= to_integer(unsigned(BIN_IN));

    d3_thousands <= bin_int / 1000;
    r_1000       <= bin_int mod 1000;

    d2_hundreds <= r_1000 / 100;
    r_100       <= r_1000 mod 100;

    d1_tens     <= r_100 / 10;
    d0_units    <= r_100 mod 10;
    
    BCD_OUT(15 downto 12) <= std_logic_vector(to_unsigned(d3_thousands, 4));
    BCD_OUT(11 downto 8)  <= std_logic_vector(to_unsigned(d2_hundreds, 4));
    BCD_OUT(7 downto 4)   <= std_logic_vector(to_unsigned(d1_tens, 4));
    BCD_OUT(3 downto 0)   <= std_logic_vector(to_unsigned(d0_units, 4));

end architecture arch5;
