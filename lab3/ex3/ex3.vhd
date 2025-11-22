library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BCD_counter is
    port (
        clk, rst: in std_logic;
        BCD: out std_logic_vector(11 downto 0)
    );
end BCD_counter;

architecture myarch of BCD_counter is
    signal temp1, temp2, temp3: integer range 0 to 9 := 0;
begin
    process(clk, rst)
    begin
        if(rst = '1') then
            temp1 <= 0;
            temp2 <= 0;
            temp3 <= 0;
        elsif (rising_edge(clk)) then
            if(temp1 = 9) then
                temp1 <= 0;
                if(temp2 = 9) then
                    temp2 <= 0;
                    if(temp3 = 9) then
                        temp3 <= 0;
                    else
                        temp3 <= temp3 + 1;
                    end if;
                else
                    temp2 <= temp2 + 1;
                end if;
            else
                temp1 <= temp1 + 1;
            end if;
        end if;
    end process;
    
    BCD(11 downto 8) <= std_logic_vector(to_unsigned(temp3, 4));
    BCD(7 downto 4) <= std_logic_vector(to_unsigned(temp2, 4));
    BCD(3 downto 0) <= std_logic_vector(to_unsigned(temp1, 4));
end myarch;