library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all; -- Added for to_string()
use ieee.math_real.all;

entity consecutive_ones_counter_tb is
end consecutive_ones_counter_tb;

architecture testbench of consecutive_ones_counter_tb is
    
    -- Constant for vector size (still useful)
    constant n : integer := 8;
    
    -- Signals
    signal x   : std_logic_vector(n-1 downto 0);
    signal y   : std_logic_vector (integer(ceil(log(real(n+1)) / log(2.0)))-1 downto 0);
    signal ssd : std_logic_vector(6 downto 0);
    
    -- Component declaration (FIXED: No generic)
    component consecutive_ones_counter is
        generic ( n : integer := 8 );  
        port ( x : in std_logic_vector (n-1 downto 0);
           y : out std_logic_vector (integer(ceil(log(real(n+1)) / log(2.0)))-1 downto 0);
           ssd : out std_logic_vector (6 downto 0));
    end component;
    
begin

    -- Instantiate Unit Under Test (UUT) (FIXED: No generic map)
    UUT: consecutive_ones_counter
        
        
        generic map(n => n)
        port map (
            x   => x,
            y   => y,
            ssd => ssd
        );

    -- Self-checking stimulus process
    stim_proc: process
    begin
        
        
        -- Test 0: All zeros -> count = 0
        x <= "00000000";
        wait for 10 ns;
        
        -- Test 1: One leading 1 -> count = 1
        x <= "10000000";
        wait for 10 ns;
        
        -- Test 2: Two leading 1s -> count = 2
        x <= "11000000";
        wait for 10 ns;
       
        -- Test 3: Three leading 1s -> count = 3
        x <= "11100000";
        wait for 10 ns;
         
        -- Test 4: Four leading 1s -> count = 4
        x <= "11110000";
        wait for 10 ns;
        
        -- Test 5: Five leading 1s -> count = 5
        x <= "11111000";
        wait for 10 ns;
       
        -- Test 6: Six leading 1s -> count = 6
        x <= "11111100";
        wait for 10 ns;
        
        -- Test 7: Seven leading 1s -> count = 7
        x <= "11111110";
        wait for 10 ns;
       
        -- Test 8: All 1s -> count = 8
        x <= "11111111";
        wait for 10 ns;
      
        
        
        
        
        wait;
        
    end process;

end testbench;
