library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity CLEFIA_RK_GEN is
    Port ( 
        L_in : in  std_logic_vector (127 downto 0); 
        K : in  std_logic_vector (127 downto 0); 
        CON: in std_logic_vector(127 downto 0);
        odd : in  std_logic;            
        RK_row : out std_logic_vector (127 downto 0); 
        L_swapped : out std_logic_vector (127 downto 0) 
    );
end CLEFIA_RK_GEN;

architecture behavioral of CLEFIA_RK_GEN is

    component CLEFIA_DOUBLE_SWAP
        Port ( input   : in  std_logic_vector (127 downto 0);
               output  : out std_logic_vector (127 downto 0));
    end component;

    signal T : std_logic_vector(127 downto 0);

begin

    T <= L_in xor CON;
    SIGMA_L: CLEFIA_DOUBLE_SWAP port map (
        input  => L_in, 
        output => L_swapped
    );

    with odd select  
        RK_row <= T when '0',
            T xor K when others;

end behavioral;