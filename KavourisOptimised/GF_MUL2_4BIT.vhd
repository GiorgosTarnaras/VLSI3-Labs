library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- This entity performs multiplication by 2 in GF(2^4) 
-- defined by the polynomial z^4 + z + 1.
entity GF_MUL2_4BIT is
    Port ( x : in  std_logic_vector (3 downto 0);
           y : out std_logic_vector (3 downto 0));
end GF_MUL2_4BIT;

architecture behavioral of GF_MUL2_4BIT is
begin
    process(x)
    begin
        -- If MSB is 0: just shift left
        -- If MSB is 1: shift left and XOR with "0011" (0x3)
        if x(3) = '0' then
            y <= x(2 downto 0) & '0';
        else
            y <= (x(2 downto 0) & '0') xor "0011";
        end if;
    end process;
end behavioral;