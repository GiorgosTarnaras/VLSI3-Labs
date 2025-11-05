library ieee;
use ieee.std_logic_1164.all;

entity exercise_2_tb is
end entity exercise_2_tb;

architecture behavioral of exercise_2_tb is
    signal r      : std_logic_vector(7 downto 0);
    signal c      : std_logic_vector(2 downto 0);
    signal code   : std_logic_vector(2 downto 0);
    signal active : std_logic;
    
begin
    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.exercise_2
        port map (
            r      => r,
            c      => c,
            code   => code,
            active => active
        );

    -- Stimulus process
    stim_proc: process
    begin
        
        r <= "11001000";
        c <= "111";
        wait for 10 ns;
        
        -- Test case 2: r="00000001", c="000"
        r <= "01001000";
        c <= "111";
        wait for 10 ns;
        
        -- Test case 3: r="01010101", c="001"
        r <= "01001000";
        c <= "100";
        wait for 10 ns;
        
        -- Test case 4: r="10101010", c="011"
        r <= "01001000";
        c <= "010";
        wait for 10 ns;
        
        -- Test case 5: r="00000000", c="000"
        r <= "01001001";
        c <= "000";
        wait for 10 ns;
        
        wait;
    end process;

end architecture behavioral;