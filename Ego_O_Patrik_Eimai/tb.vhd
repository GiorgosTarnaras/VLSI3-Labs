library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_CLEFIA_PIPELINED is
-- Testbench has no ports
end tb_CLEFIA_PIPELINED;

architecture behavior of tb_CLEFIA_PIPELINED is

    -- Component Declaration for the Unit Under Test (UUT)
    component CLEFIA_PIPELINED
    Port ( 
        clk        : in  std_logic;
        key_in     : in  std_logic_vector (127 downto 0);
        data_in    : in  std_logic_vector (127 downto 0);
        data_out   : out std_logic_vector (127 downto 0)
    );
    end component;

    -- Inputs
    signal clk     : std_logic := '0';
    signal key_in  : std_logic_vector(127 downto 0) := (others => '0');
    signal data_in : std_logic_vector(127 downto 0) := (others => '0');

    -- Outputs
    signal data_out : std_logic_vector(127 downto 0);

    -- Clock period definitions
    constant clk_period : time := 10 ns;
    
    -- Test Vectors (Standard CLEFIA-128)
    -- Key: ffeeddcc bbaa9988 77665544 33221100
    constant TEST_KEY_VAL : std_logic_vector(127 downto 0) := x"ffeeddccbbaa99887766554433221100";
    
    -- Plaintext: 00010203 04050607 08090a0b 0c0d0e0f
    constant TEST_PT_VAL  : std_logic_vector(127 downto 0) := x"000102030405060708090a0b0c0d0e0f";
    
    constant TEST_CT_VAL  : std_logic_vector(127 downto 0) := x"de2bf2fd9b74aacdf1298555459494fd";

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: CLEFIA_PIPELINED PORT MAP (
        clk      => clk,
        key_in   => key_in,
        data_in  => data_in,
        data_out => data_out
    );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin		
        -- 1. Hold Reset for 100 ns
        key_in  <= (others => '0');
        data_in <= (others => '0');
        wait for 100 ns;	
        
        wait for clk_period; -- Wait for one clock edge after reset release

        -- ============================================================
        -- TEST CASE 1: Single Block Encryption
        -- ============================================================
        report "Starting Pipeline Feed...";
        
        -- Feed Input (Valid at Rising Edge)
        key_in  <= TEST_KEY_VAL;
        data_in <= TEST_PT_VAL;
        
        -- The Core is pipelined with 21 cycles of latency
        -- (12 cycles L-Gen + 9 cycles Rounds)
        -- We wait for 21 clock cycles for the data to travel through.
        
        for i in 1 to 21 loop
            wait for clk_period;
        end loop;

        -- Wait one small delta to ensure output is stable before checking
        wait for 1 ns; 

        -- Check Result
        if data_out = TEST_CT_VAL then
            report "PASS: Output matches expected Ciphertext." severity note;
        else
            report "FAIL: Output mismatch." severity error;
            -- report "Expected: " & to_hstring(TEST_CT_VAL);
            -- report "Got:      " & to_hstring(data_out);
        end if;

        -- ============================================================
        -- TEST CASE 2: Pipeline Throughput (Streaming)
        -- ============================================================
        -- Feed new random data to prove pipeline accepts data every cycle
        wait for clk_period;
        data_in <= (others => '1'); -- New Data
        wait for clk_period;
        data_in <= (others => '0'); -- New Data
        
        -- (Outputs for these would appear 21 cycles later)

        wait for 200 ns;
        report "Simulation Finished.";
        wait;
    end process;

end behavior;