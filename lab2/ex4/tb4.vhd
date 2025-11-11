-- This is a testbench for the arithmetic_unit entity.
-- It applies a series of test vectors to the inputs
-- and allows for observation of the outputs in a simulator.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; -- Good to have for conversions, though not strictly needed here

entity arithmetic_unit_tb is
    -- Testbench entity is typically empty
end entity arithmetic_unit_tb;

architecture test_bench of arithmetic_unit_tb is

    -- 1. Define the component to be tested (your DUT)
    -- This declaration must match the entity in your original file.
    component arithmetic_unit is
        generic (
            n : positive := 4
        );
        port (
            a    : in  std_logic_vector(n - 1 downto 0);
            b    : in  std_logic_vector(n - 1 downto 0);
            cin  : in  std_logic;
            code : in  std_logic_vector(2 downto 0);
            y    : out std_logic_vector(n - 1 downto 0);
            cout : out std_logic;
            ovf  : out std_logic
        );
    end component arithmetic_unit;

    -- 2. Define testbench constants
    constant N_BITS : positive := 4;
    constant T_DELAY : time := 10 ns; -- Time between test vectors

    -- 3. Define signals to connect to the DUT
    -- Inputs
    signal tb_a    : std_logic_vector(N_BITS - 1 downto 0) := (others => '0');
    signal tb_b    : std_logic_vector(N_BITS - 1 downto 0) := (others => '0');
    signal tb_cin  : std_logic := '0';
    signal tb_code : std_logic_vector(2 downto 0) := (others => '0');

    -- Outputs
    signal tb_y    : std_logic_vector(N_BITS - 1 downto 0);
    signal tb_cout : std_logic;
    signal tb_ovf  : std_logic;

begin

    -- 4. Instantiate the Device Under Test (DUT)
    dut_inst : arithmetic_unit
        generic map (
            n => N_BITS
        )
        port map (
            a    => tb_a,
            b    => tb_b,
            cin  => tb_cin,
            code => tb_code,
            y    => tb_y,
            cout => tb_cout,
            ovf  => tb_ovf
        );

    -- 5. Create the stimulus process
    stimulus_proc : process
    begin
        report "Starting Arithmetic Unit Testbench...";

        -- Test 000: y=a+b (unsigned)
        -- Case 1: 5 + 2 = 7 (no overflow)
        tb_code <= "000";
        tb_a    <= "0101"; -- 5
        tb_b    <= "0010"; -- 2
        tb_cin  <= '0'; -- Ignored by this operation
        wait for T_DELAY;
        -- Expected: y="0111", cout='0', ovf='0'

        -- Case 2: 15 + 1 = 16 -> 0 (unsigned overflow)
        tb_a    <= "1111"; -- 15
        tb_b    <= "0001"; -- 1
        wait for T_DELAY;
        -- Expected: y="0000", cout='1', ovf='1'

        -- Test 001: y=a-b (unsigned)
        -- Case 1: 7 - 2 = 5 (no overflow)
        tb_code <= "001";
        tb_a    <= "0111"; -- 7
        tb_b    <= "0010"; -- 2
        wait for T_DELAY;
        -- Expected: y="0101", cout='1', ovf='0' (cout=1 for no borrow)

        -- Case 2: 2 - 7 = -5 -> 11 (unsigned overflow/borrow)
        tb_a    <= "0010"; -- 2
        tb_b    <= "0111"; -- 7
        wait for T_DELAY;
        -- Expected: y="1011", cout='0', ovf='1' (cout=0 for borrow)

        -- Test 010: y=b-a (unsigned)
        -- Case 1: 7 - 2 = 5 (b=7, a=2)
        tb_code <= "010";
        tb_a    <= "0010"; -- 2
        tb_b    <= "0111"; -- 7
        wait for T_DELAY;
        -- Expected: y="0101", cout='1', ovf='0'

        -- Test 011: y=a+b+cin (unsigned)
        -- Case 1: 5 + 2 + 1 = 8
        tb_code <= "011";
        tb_a    <= "0101"; -- 5
        tb_b    <= "0010"; -- 2
        tb_cin  <= '1';
        wait for T_DELAY;
        -- Expected: y="1000", cout='0', ovf='0'

        -- Test 100: y=a+b (signed)
        -- Case 1: 3 + 2 = 5
        tb_code <= "100";
        tb_a    <= "0011"; -- 3
        tb_b    <= "0010"; -- 2
        tb_cin  <= '0'; -- Ignored
        wait for T_DELAY;
        -- Expected: y="0101", cout='0', ovf='0'

        -- Case 2: 4 + 5 = 9 (signed overflow, 4+5 > 7)
        tb_a    <= "0100"; -- 4
        tb_b    <= "0101"; -- 5
        wait for T_DELAY;
        -- Expected: y="1001" (-7), cout='0', ovf='1'

        -- Case 3: -8 + -7 = -15 (signed overflow, -8 + -7 < -8)
        tb_a    <= "1000"; -- -8
        tb_b    <= "1001"; -- -7
        wait for T_DELAY;
        -- Expected: y="0001" (1), cout='1', ovf='1'

        -- Test 101: y=a-b (signed)
        -- Case 1: 5 - 2 = 3
        tb_code <= "101";
        tb_a    <= "0101"; -- 5
        tb_b    <= "0010"; -- 2
        wait for T_DELAY;
        -- Expected: y="0011", cout='1', ovf='0'

        -- Case 2: 7 - (-8) = 15 (signed overflow)
        tb_a    <= "0111"; -- 7
        tb_b    <= "1000"; -- -8
        wait for T_DELAY;
        -- Expected: y="1111" (-1), cout='0', ovf='1'

        -- Test 110: y=b-a (signed)
        -- Case 1: -8 - 7 = -15 (signed overflow)
        tb_code <= "110";
        tb_a    <= "0111"; -- 7
        tb_b    <= "1000"; -- -8
        wait for T_DELAY;
        -- Expected: y="0001" (1), cout='0', ovf='1'

        -- Test 111: y=a+b+cin (signed)
        -- Case 1: 2 + 3 + 1 = 6
        tb_code <= "111";
        tb_a    <= "0010"; -- 2
        tb_b    <= "0011"; -- 3
        tb_cin  <= '1';
        wait for T_DELAY;
        -- Expected: y="0110", cout='0', ovf='0'

        -- End of tests
        report "Testbench finished.";
        wait; -- Stop the simulation

    end process stimulus_proc;

end architecture test_bench;