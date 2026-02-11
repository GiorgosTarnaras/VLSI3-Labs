library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- FIXED: Entity name is now unique
entity CLEFIA_ROUND_INV is
    Port ( 
        data_in  : in  std_logic_vector (127 downto 0); 
        rk0      : in  std_logic_vector (31 downto 0);  
        rk1      : in  std_logic_vector (31 downto 0);  
        data_out : out std_logic_vector (127 downto 0)  
    );
end CLEFIA_ROUND_INV;

architecture structural of CLEFIA_ROUND_INV is

    component CLEFIA_F0 is
        port(rk: in std_logic_vector(31 downto 0); x: in std_logic_vector(31 downto 0); y: out std_logic_vector(31 downto 0));
    end component;

    component CLEFIA_F1 is
        port(rk: in std_logic_vector(31 downto 0); x: in std_logic_vector(31 downto 0); y: out std_logic_vector(31 downto 0));
    end component;

    signal t0, t1, t2, t3 : std_logic_vector(31 downto 0);
    signal v0, v1 : std_logic_vector(31 downto 0);
    signal t1_updated, t3_updated : std_logic_vector(31 downto 0);

begin
    -- Split input: T0 T1 T2 T3
    t0 <= data_in(127 downto 96);
    t1 <= data_in(95 downto 64);
    t2 <= data_in(63 downto 32);
    t3 <= data_in(31 downto 0);

    -- F-functions
    U_F0: CLEFIA_F0 port map (rk => rk0, x => t0, y => v0);
    U_F1: CLEFIA_F1 port map (rk => rk1, x => t2, y => v1);

    t1_updated <= t1 xor v0;
    t3_updated <= t3 xor v1;

    data_out <= t3_updated & t0 & t1_updated & t2;

end structural;