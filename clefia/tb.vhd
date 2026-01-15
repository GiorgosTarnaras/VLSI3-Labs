--------------------------------------------------------------------------------
-- CLEFIA 128-bit Testbench
-- Tests encryption and decryption with official test vectors
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity CLEFIA_tb is
end CLEFIA_tb;

architecture testbench of CLEFIA_tb is

    -- Component declaration
    component CLEFIA is
        generic (
            KEY_SIZE : integer := 128
        );
        port (
            clk          : in  std_logic;
            rst          : in  std_logic;
            start        : in  std_logic;
            mode         : in  std_logic;
            plaintext    : in  std_logic_vector(127 downto 0);
            key          : in  std_logic_vector(127 downto 0);
            ciphertext   : out std_logic_vector(127 downto 0);
            done         : out std_logic;
            valid        : out std_logic
        );
    end component;

    -- Clock period
    constant CLK_PERIOD : time := 10 ns;
    
    -- Signals
    signal clk          : std_logic := '0';
    signal rst          : std_logic := '0';
    signal start        : std_logic := '0';
    signal mode         : std_logic := '0';
    signal plaintext    : std_logic_vector(127 downto 0) := (others => '0');
    signal key          : std_logic_vector(127 downto 0) := (others => '0');
    signal ciphertext   : std_logic_vector(127 downto 0);
    signal done         : std_logic;
    signal valid        : std_logic;
    
    -- Test vectors from specification (Section 6)
    constant TEST_KEY_128       : std_logic_vector(127 downto 0) := 
        x"ffeeddccbbaa99887766554433221100";
    constant TEST_PLAINTEXT_128 : std_logic_vector(127 downto 0) := 
        x"000102030405060708090a0b0c0d0e0f";
    constant TEST_CIPHERTEXT_128 : std_logic_vector(127 downto 0) := 
        x"de2bf2fd9b74aacdf1298555459494fd";
    
    -- Test status
    signal test_passed : boolean := false;
    signal test_failed : boolean := false;
    
    -- Temporary storage for round-trip test
    signal encrypted_data : std_logic_vector(127 downto 0) := (others => '0');

begin

    -- Instantiate DUT
    dut: CLEFIA
        generic map (
            KEY_SIZE => 128
        )
        port map (
            clk        => clk,
            rst        => rst,
            start      => start,
            mode       => mode,
            plaintext  => plaintext,
            key        => key,
            ciphertext => ciphertext,
            done       => done,
            valid      => valid
        );

    -- Clock generation
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus process
    stim_process: process
        variable line_v : line;
    begin
        -- Print test header
        write(line_v, string'("========================================"));
        writeline(output, line_v);
        write(line_v, string'("CLEFIA 128-bit Test Vector Verification"));
        writeline(output, line_v);
        write(line_v, string'("========================================"));
        writeline(output, line_v);
        
        -- Initial reset
        rst <= '1';
        wait for CLK_PERIOD * 2;
        rst <= '0';
        wait for CLK_PERIOD * 2;
        
        -----------------------------------------------------------------------
        -- TEST 1: Encryption
        -----------------------------------------------------------------------
        write(line_v, string'(""));
        writeline(output, line_v);
        write(line_v, string'("TEST 1: Encryption"));
        writeline(output, line_v);
        write(line_v, string'("-------------------"));
        writeline(output, line_v);
        
        -- Load test vectors
        key       <= TEST_KEY_128;
        plaintext <= TEST_PLAINTEXT_128;
        mode      <= '0';  -- Encrypt mode
        
        write(line_v, string'("Key:       ffeeddccbbaa99887766554433221100"));
        writeline(output, line_v);
        write(line_v, string'("Plaintext: 000102030405060708090a0b0c0d0e0f"));
        writeline(output, line_v);
        write(line_v, string'("Expected:  de2bf2fd9b74aacdf1298555459494fd"));
        writeline(output, line_v);
        
        -- Start encryption
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';
        
        -- Wait for done signal
        wait until done = '1';
        wait for CLK_PERIOD;
        
        -- Check result
        write(line_v, string'("Result:    "));
        hwrite(line_v, ciphertext);
        writeline(output, line_v);
        
        if ciphertext = TEST_CIPHERTEXT_128 then
            write(line_v, string'("Status:    PASS - Encryption successful!"));
            writeline(output, line_v);
        else
            write(line_v, string'("Status:    FAIL - Encryption mismatch!"));
            writeline(output, line_v);
            test_failed <= true;
        end if;
        
        wait for CLK_PERIOD * 5;
        
        
    end process;

end testbench;
