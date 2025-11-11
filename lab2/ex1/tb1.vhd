library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity barrel_shifter_tb is
end barrel_shifter_tb;

architecture testbench of barrel_shifter_tb is
    
    -- Component declaration
    component barrel_shifter
        Port ( a   : in  std_logic_vector(7 downto 0);
               lar : in  std_logic_vector(1 downto 0);  
               amt : in  std_logic_vector(2 downto 0);  
               y   : out std_logic_vector(7 downto 0));
    end component;
    
    -- Test signals
    signal a_tb   : std_logic_vector(7 downto 0) := (others => '0');
    signal lar_tb : std_logic_vector(1 downto 0) := (others => '0');
    signal amt_tb : std_logic_vector(2 downto 0) := (others => '0');
    signal y_tb   : std_logic_vector(7 downto 0);
    
    -- Test patterns
    constant test_val1 : std_logic_vector(7 downto 0) := "10110011"; -- 0xB3
    constant test_val2 : std_logic_vector(7 downto 0) := "11001010"; -- 0xCA
    constant test_val3 : std_logic_vector(7 downto 0) := "00001111"; -- 0x0F
    
begin
    
    -- Instantiate the Unit Under Test (UUT)
    uut: barrel_shifter
        port map (
            a   => a_tb,
            lar => lar_tb,
            amt => amt_tb,
            y   => y_tb
        );
    
    -- Stimulus process
    stim_proc: process
    begin
        
        report "Starting Barrel Shifter Testbench";
        
        -- Test 1: No shift (amt = "000")
        report "Test 1: No shift";
        a_tb <= test_val1;
        amt_tb <= "000";
        lar_tb <= "00";
        wait for 10 ns;
        assert y_tb = test_val1 report "Test 1 failed!" severity error;
        
        -- Test 2: Logical right shift tests (lar = "00")
        report "Test 2: Logical Right Shifts";
        a_tb <= test_val1;
        lar_tb <= "00";
        
        amt_tb <= "001"; wait for 10 ns; -- shift right 1
        report "Logical right 1: " & integer'image(to_integer(unsigned(y_tb)));
        
        amt_tb <= "010"; wait for 10 ns; -- shift right 2
        report "Logical right 2: " & integer'image(to_integer(unsigned(y_tb)));
        
        amt_tb <= "011"; wait for 10 ns; -- shift right 3
        report "Logical right 3: " & integer'image(to_integer(unsigned(y_tb)));
        
        amt_tb <= "100"; wait for 10 ns; -- shift right 4
        report "Logical right 4: " & integer'image(to_integer(unsigned(y_tb)));
        
        amt_tb <= "101"; wait for 10 ns; -- shift right 5
        amt_tb <= "110"; wait for 10 ns; -- shift right 6
        amt_tb <= "111"; wait for 10 ns; -- shift right 7
        
        -- Test 3: Arithmetic right shift tests (lar = "01")
        report "Test 3: Arithmetic Right Shifts";
        a_tb <= test_val2; -- negative number (MSB = 1)
        lar_tb <= "01";
        
        amt_tb <= "001"; wait for 10 ns; -- shift right 1
        report "Arithmetic right 1: " & integer'image(to_integer(unsigned(y_tb)));
        
        amt_tb <= "010"; wait for 10 ns; -- shift right 2
        amt_tb <= "011"; wait for 10 ns; -- shift right 3
        amt_tb <= "100"; wait for 10 ns; -- shift right 4
        amt_tb <= "101"; wait for 10 ns; -- shift right 5
        amt_tb <= "110"; wait for 10 ns; -- shift right 6
        amt_tb <= "111"; wait for 10 ns; -- shift right 7
        
        -- Test 4: Rotate right tests (lar = "10" or "11")
        report "Test 4: Rotate Right";
        a_tb <= test_val1;
        lar_tb <= "10";
        
        amt_tb <= "001"; wait for 10 ns; -- rotate right 1
        report "Rotate right 1: " & integer'image(to_integer(unsigned(y_tb)));
        
        amt_tb <= "010"; wait for 10 ns; -- rotate right 2
        amt_tb <= "011"; wait for 10 ns; -- rotate right 3
        amt_tb <= "100"; wait for 10 ns; -- rotate right 4
        amt_tb <= "101"; wait for 10 ns; -- rotate right 5
        amt_tb <= "110"; wait for 10 ns; -- rotate right 6
        amt_tb <= "111"; wait for 10 ns; -- rotate right 7
        
        -- Test 5: Edge cases
        report "Test 5: Edge Cases";
        
        -- All zeros
        a_tb <= "00000000";
        amt_tb <= "011";
        lar_tb <= "00";
        wait for 10 ns;
        assert y_tb = "00000000" report "All zeros test failed!" severity error;
        
        -- All ones
        a_tb <= "11111111";
        amt_tb <= "011";
        lar_tb <= "00";
        wait for 10 ns;
        assert y_tb = "00011111" report "All ones logical shift failed!" severity error;
        
        -- All ones with arithmetic shift
        a_tb <= "11111111";
        amt_tb <= "011";
        lar_tb <= "01";
        wait for 10 ns;
        assert y_tb = "11111111" report "All ones arithmetic shift failed!" severity error;
        
        -- Test with different value
        a_tb <= test_val3;
        amt_tb <= "010";
        lar_tb <= "10";
        wait for 10 ns;
        
        report "Testbench completed successfully!";
        wait;
        
    end process;
    
end testbench;