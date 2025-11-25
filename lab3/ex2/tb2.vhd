library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_universal_counter is
end tb_universal_counter;

architecture testbench of tb_universal_counter is

    component universal_binary_counter
        Port ( 
            clk        : in  std_logic;
            reset      : in  std_logic;
            synch_clr  : in  std_logic;
            load       : in  std_logic;
            en         : in  std_logic;
            up         : in  std_logic;
            d          : in  std_logic_vector(3 downto 0);
            Q          : out std_logic_vector(3 downto 0);
            max        : out std_logic;
            min        : out std_logic
        );
    end component;
    
    signal clk       : std_logic := '0';
    signal reset     : std_logic := '0';
    signal synch_clr : std_logic := '0';
    signal load      : std_logic := '0';
    signal en        : std_logic := '0';
    signal up        : std_logic := '1';
    signal d         : std_logic_vector(3 downto 0) := (others => '0');
    signal Q         : std_logic_vector(3 downto 0);
    signal max       : std_logic;
    signal min       : std_logic;
    

    constant CLK_PERIOD : time := 8 ns;
    constant SETUP_TIME : time := 1 ns;
    signal sim_done : boolean := false;
    
begin
    uut: universal_binary_counter
        port map (
            clk       => clk,
            reset     => reset,
            synch_clr => synch_clr,
            load      => load,
            en        => en,
            up        => up,
            d         => d,
            Q         => Q,
            max       => max,
            min       => min
        );
    
    -- Clock generation
    clk_process: process
    begin
        while not sim_done loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;
    

    stim_process: process
    begin
        wait for 100ns;
        wait for CLK_PERIOD * 2;
        

        d <= "1010";
        wait for CLK_PERIOD - SETUP_TIME;
        load <= '1';
        wait for CLK_PERIOD + SETUP_TIME;
        load <= '0';
        wait for CLK_PERIOD;
        wait for CLK_PERIOD - SETUP_TIME;
        reset <= '1';
        wait for CLK_PERIOD * 2;  
        wait for CLK_PERIOD - SETUP_TIME;
        reset <= '0';
        wait for CLK_PERIOD + SETUP_TIME;

        assert Q = "0000" report "Async reset failed: Q=" & integer'image(to_integer(unsigned(Q))) severity error;
        assert min = '1' report "Min flag not set after reset" severity error;
        wait for CLK_PERIOD;
        
 
        d <= "0111";
        wait for CLK_PERIOD - SETUP_TIME;
        load <= '1';
        wait for CLK_PERIOD + SETUP_TIME;
        load <= '0';
        wait for CLK_PERIOD;
        assert Q = "0111" report "Load before clear failed: Q=" & integer'image(to_integer(unsigned(Q))) severity error;
        wait for CLK_PERIOD - SETUP_TIME;
        synch_clr <= '1';
        wait for CLK_PERIOD + SETUP_TIME;
        synch_clr <= '0';
        wait for CLK_PERIOD;
        assert Q = "0000" report "Synchronous clear failed: Q=" & integer'image(to_integer(unsigned(Q))) severity error;
        assert min = '1' report "Min flag not set after synch_clr" severity error;
        wait for CLK_PERIOD;
        
      
        report "=== Test 3: Parallel Load ===";
        d <= "1100";
        en <= '0';
        wait for CLK_PERIOD - SETUP_TIME;
        load <= '1';
        wait for CLK_PERIOD + SETUP_TIME;
        load <= '0';
        wait for CLK_PERIOD;
        assert Q = "1100" report "Parallel load failed: Q=" & integer'image(to_integer(unsigned(Q))) severity error;
        wait for CLK_PERIOD;
        

        report "=== Test 4: Count Up from 12 ===";
        wait for CLK_PERIOD - SETUP_TIME;
        en <= '1';
        up <= '1';
        wait for CLK_PERIOD + SETUP_TIME;
        
        wait for CLK_PERIOD;
        assert Q = "1101" report "Count up 12->13 failed: Q=" & integer'image(to_integer(unsigned(Q))) severity error;
        wait for CLK_PERIOD;
        assert Q = "1110" report "Count up 13->14 failed: Q=" & integer'image(to_integer(unsigned(Q))) severity error;
        wait for CLK_PERIOD;
        assert Q = "1111" report "Count up 14->15 failed: Q=" & integer'image(to_integer(unsigned(Q))) severity error;
        assert max = '1' report "Max flag not set at 15" severity error;
        wait for CLK_PERIOD;
        assert Q = "0000" report "Wrap around 15->0 failed: Q=" & integer'image(to_integer(unsigned(Q))) severity error;
        assert min = '1' report "Min flag not set after wrap" severity error;
        wait for CLK_PERIOD;
        

        report "=== Test 5: Pause ===";
        assert Q = "0001" report "Pre-pause count failed: Q=" & integer'image(to_integer(unsigned(Q))) severity error;
        wait for CLK_PERIOD - SETUP_TIME;
        en <= '0';
        wait for CLK_PERIOD + SETUP_TIME;
        wait for CLK_PERIOD * 3;
        assert Q = "0001" report "Counter did not pause: Q=" & integer'image(to_integer(unsigned(Q))) severity error;
        wait for CLK_PERIOD;
        
 
        report "=== Test 6: Count Down ===";
        d <= "0101";  -- Load 5
        wait for CLK_PERIOD - SETUP_TIME;
        load <= '1';
        wait for CLK_PERIOD + SETUP_TIME;
        load <= '0';
        en <= '1';
        up <= '0';
        wait for CLK_PERIOD + SETUP_TIME;
        
        wait for CLK_PERIOD;
        assert Q = "0100" report "Count down 5->4 failed: Q=" & integer'image(to_integer(unsigned(Q))) severity error;
        wait for CLK_PERIOD * 4;
        assert Q = "0000" report "Count down to 0 failed: Q=" & integer'image(to_integer(unsigned(Q))) severity error;
        assert min = '1' report "Min flag not set" severity error;
        wait for CLK_PERIOD;
        assert Q = "1111" report "Underflow 0->15 failed: Q=" & integer'image(to_integer(unsigned(Q))) severity error;
        assert max = '1' report "Max flag not set after underflow" severity error;
        wait for CLK_PERIOD * 2;
        

        report "=== Test 7: Priority - synch_clr beats load and en ===";
        d <= "1000";
        wait for CLK_PERIOD - SETUP_TIME;
        synch_clr <= '1';
        load <= '1';
        en <= '1';
        up <= '1';
        wait for CLK_PERIOD + SETUP_TIME;
        wait for CLK_PERIOD;
        assert Q = "0000" report "synch_clr priority failed: Q=" & integer'image(to_integer(unsigned(Q))) severity error;
        
        report "=== Test 8: Priority - load beats en ===";
        synch_clr <= '0';
        d <= "0110";
        wait for CLK_PERIOD - SETUP_TIME;
        load <= '1';
        en <= '1';
        up <= '1';
        wait for CLK_PERIOD + SETUP_TIME;
        wait for CLK_PERIOD;
        assert Q = "0110" report "load priority over en failed: Q=" & integer'image(to_integer(unsigned(Q))) severity error;
        
        report "=== Test 9: Priority - en works when load=0 ===";
        wait for CLK_PERIOD - SETUP_TIME;
        load <= '0';
        en <= '1';
        up <= '1';
        wait for CLK_PERIOD + SETUP_TIME;
        wait for CLK_PERIOD;
        assert Q = "0111" report "en operation after load failed: Q=" & integer'image(to_integer(unsigned(Q))) severity error;
        wait for CLK_PERIOD;
        

        report "=== Test 10: Full Count Up Sequence ===";
        wait for CLK_PERIOD - SETUP_TIME;
        synch_clr <= '1';
        wait for CLK_PERIOD + SETUP_TIME;
        synch_clr <= '0';
        en <= '1';
        up <= '1';
        wait for CLK_PERIOD + SETUP_TIME;
        for i in 0 to 16 loop
            wait for CLK_PERIOD;
        end loop;
        assert Q = "0001" report "Full count sequence failed: Q=" & integer'image(to_integer(unsigned(Q))) severity error;
        

        report "=== Test 11: Full Count Down Sequence ===";
        wait for CLK_PERIOD - SETUP_TIME;
        up <= '0';
        wait for CLK_PERIOD + SETUP_TIME;
        for i in 0 to 16 loop
            wait for CLK_PERIOD;
        end loop;
        assert Q = "0000" report "Full count down sequence failed: Q=" & integer'image(to_integer(unsigned(Q))) severity error;
        
  
        report "=== Test 12: Load Max Value ===";
        d <= "1111";
        en <= '0';
        wait for CLK_PERIOD - SETUP_TIME;
        load <= '1';
        wait for CLK_PERIOD + SETUP_TIME;
        wait for CLK_PERIOD;
        assert max = '1' report "Max flag not set after load max" severity error;
        
        report "=== Test 13: Load Min Value ===";
        d <= "0000";
        wait for CLK_PERIOD + SETUP_TIME;
        wait for CLK_PERIOD;
        load <= '0';
        wait for CLK_PERIOD;
        assert min = '1' report "Min flag not set after load min" severity error;
        
        wait for CLK_PERIOD * 2;
        report "========================================";
        report "All tests completed successfully!";
        report "========================================";
        sim_done <= true;
        wait;
    end process;

end testbench;
