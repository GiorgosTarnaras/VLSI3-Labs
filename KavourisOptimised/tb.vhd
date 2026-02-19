library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_CLEFIA_128_CORE is
-- Testbench has no ports
end tb_CLEFIA_128_CORE;

architecture behavior of tb_CLEFIA_128_CORE is

    -- ============================================================
    -- Component Declaration
    -- ============================================================
    component CLEFIA_128_CORE
    Port ( 
        clk        : in  std_logic;
        rst        : in  std_logic;
        start      : in  std_logic;
        is_decrypt : in  std_logic; -- 0: Encrypt, 1: Decrypt
        key_in     : in  std_logic_vector (127 downto 0);
        data_in    : in  std_logic_vector (127 downto 0);
        data_out   : out std_logic_vector (127 downto 0);
        done       : out std_logic
    );
    end component;

    -- ============================================================
    -- Signals
    -- ============================================================
    signal clk        : std_logic := '0';
    signal rst        : std_logic := '0';
    signal start      : std_logic := '0';
    signal is_decrypt : std_logic := '0';
    signal key_in     : std_logic_vector(127 downto 0) := (others => '0');
    signal data_in    : std_logic_vector(127 downto 0) := (others => '0');

    -- Outputs
    signal data_out   : std_logic_vector(127 downto 0);
    signal done       : std_logic;

    -- Clock period definition
    constant clk_period : time := 10 ns;
    
    -- ============================================================
    -- Test Vectors (From CLEFIA Spec, Page 26) [cite: 632-638]
    -- ============================================================
    -- Key: ffeeddcc bbaa9988 77665544 33221100
    constant TEST_KEY_VAL : std_logic_vector(127 downto 0) := x"ffeeddccbbaa99887766554433221100";
    
    -- Plaintext: 00010203 04050607 08090a0b 0c0d0e0f
    constant TEST_PT_VAL  : std_logic_vector(127 downto 0) := x"000102030405060708090a0b0c0d0e0f";
    
    -- Ciphertext: de2bf2fd 9b74aacd f1298555 459494fd
    constant TEST_CT_VAL  : std_logic_vector(127 downto 0) := x"de2bf2fd9b74aacdf1298555459494fd";

begin

    -- ============================================================
    -- Instantiate the Unit Under Test (UUT)
    -- ============================================================
    uut: CLEFIA_128_CORE PORT MAP (
        clk        => clk,
        rst        => rst,
        start      => start,
        is_decrypt => is_decrypt,
        key_in     => key_in,
        data_in    => data_in,
        data_out   => data_out,
        done       => done
    );

    -- ============================================================
    -- Clock Process
    -- ============================================================
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- ============================================================
    -- Stimulus Process
    -- ============================================================
    stim_proc: process
    begin        
        -- 1. Apply Asynchronous Reset
        rst <= '1';
        wait for 100 ns;    
        rst <= '0';
        wait for clk_period*10;

        -- ============================================================
        -- TEST CASE 1: ENCRYPTION
        -- ============================================================
        report "Starting TEST CASE 1: Encryption";
        
        -- Setup inputs
        key_in     <= TEST_KEY_VAL;
        data_in    <= TEST_PT_VAL;       -- Load Plaintext
        is_decrypt <= '0';               -- Select Encryption Mode
        start      <= '0';
        wait for clk_period;

        -- Start pulse
        start <= '1';
        wait for clk_period;
        start <= '0';

        -- Wait for processing to finish
        wait until done = '1';
        wait for clk_period; -- Sample slightly after edge

        -- Check result
        if data_out = TEST_CT_VAL then
            report "Encryption PASSED: Output matches expected Ciphertext." severity note;
        else
            report "Encryption FAILED: Output does NOT match expected Ciphertext." severity error;
        end if;

        
        -- Idle wait between tests
        wait for 100 ns;
        
        -- ============================================================
        -- TEST CASE 2: DECRYPTION
        -- ============================================================
        report "Starting TEST CASE 2: Decryption";
        
        -- Reset UUT to clear internal state (Optional but good practice)
        rst <= '1';
        wait for clk_period * 2;
        rst <= '0';
        wait for clk_period * 5;

        -- Setup inputs
        key_in     <= TEST_KEY_VAL;     -- Same Key
        data_in    <= TEST_CT_VAL;      -- Load Ciphertext (result of encryption)
        is_decrypt <= '1';              -- Select Decryption Mode
        start      <= '0';
        wait for clk_period;

        -- Start pulse
        start <= '1';
        wait for clk_period;
        start <= '0';

        -- Wait for processing to finish
        wait until done = '1';
        wait for clk_period; -- Sample slightly after edge

        -- Check result
        if data_out = TEST_PT_VAL then
            report "Decryption PASSED: Output matches expected Plaintext." severity note;
        else
            report "Decryption FAILED: Output does NOT match expected Plaintext." severity error;
        end if;

        -- End Simulation
        wait for 100 ns;
        report "Simulation Finished.";
        
        -- Stop simulation gracefully
        assert false report "End of Simulation" severity failure;
        wait;
    end process;

end behavior;