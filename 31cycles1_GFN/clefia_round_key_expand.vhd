library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity CLEFIA_Key_Row_Gen is
    Port ( 
        L  : in  std_logic_vector (127 downto 0); 
        con0 :  in  std_logic_vector(31 downto 0);
        con1 :  in  std_logic_vector(31 downto 0);
        con2 :  in  std_logic_vector(31 downto 0);
        con3 :  in  std_logic_vector(31 downto 0);
        K       : in  std_logic_vector(127 downto 0); 
        counter : in  integer range 0 to 8;           
        RK_Row  : out std_logic_vector(127 downto 0)
    );
end CLEFIA_Key_Row_Gen;

architecture Behavioral of CLEFIA_Key_Row_Gen is
signal con_full : std_logic_vector(127 downto 0);
    signal T        : std_logic_vector(127 downto 0);
    signal base_idx : integer range 0 to 59;

begin
    con_full <= con0 & con1 & con2 & con3;
    T <= L xor con_full;
    process(T, K, counter)
    begin
        if (counter mod 2 /= 0) then
            
            RK_Row <= T xor K;
        else
            RK_Row <= T;
        end if;
    end process;

end Behavioral;