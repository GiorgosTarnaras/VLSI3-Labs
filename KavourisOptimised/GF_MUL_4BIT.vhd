library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity GF_MUL_4BIT is
    Port ( v, w : in  std_logic_vector (3 downto 0);
           y    : out std_logic_vector (3 downto 0));
end GF_MUL_4BIT;

architecture structural of GF_MUL_4BIT is

    component GF_MUL2_4BIT 
        Port ( x : in  std_logic_vector (3 downto 0);
               y : out std_logic_vector (3 downto 0));
    end component;

    -- Intermediate signals to hold the multiplied values
    signal v_times_2 : std_logic_vector(3 downto 0);
    signal v_times_4 : std_logic_vector(3 downto 0);
    signal v_times_8 : std_logic_vector(3 downto 0);

begin

    -- Instantiate the components to create the multiplication chain
    MULT2_1: GF_MUL2_4BIT port map (x => v,         y => v_times_2);
    MULT2_2: GF_MUL2_4BIT port map (x => v_times_2, y => v_times_4);
    MULT2_3: GF_MUL2_4BIT port map (x => v_times_4, y => v_times_8);

    -- Process to XOR the results based on the bits of 'w'
    process(v, w, v_times_2, v_times_4, v_times_8)
        variable p : std_logic_vector(3 downto 0);
    begin
        p := "0000";
        if w(0) = '1' then p := p xor v;         end if;
        if w(1) = '1' then p := p xor v_times_2; end if;
        if w(2) = '1' then p := p xor v_times_4; end if;
        if w(3) = '1' then p := p xor v_times_8; end if;
        
        y <= p;
    end process;

end structural;