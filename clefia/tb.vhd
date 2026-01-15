--------------------------------------------------------------------------------
-- CLEFIA 128-bit Testbench
-- Verifies functionality using Test Vectors from Specification Section 6
-- Source: CLEFIA Specification, Page 26 
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb_CLEFIA is
end tb_CLEFIA;

architecture behavior of tb_CLEFIA is

    -- Component Declaration
    component CLEFIA
        generic ( KEY_SIZE : integer := 128 );
        port (
            clk         : in  std_logic;
            rst         : in  std_logic;
            start       : in  std_logic;
            mode        : in  std_logic; -- '0' for encrypt, '1' for decrypt
            plaintext   : in  std_logic_vector(127 downto 0);
            key         : in  std_logic_vector(127 downto 0);
            ciphertext  : out std_logic_vector(127 downto 0);
            done        : out std_logic;
            valid       : out std_logic
        );
    end component;

    -- Signals
    signal clk        : std_logic := '0';
    signal rst        : std_logic := '0';
    signal start      : std_logic := '0';
    signal mode       : std_logic := '0';
    signal plaintext  : std_logic_vector(127 downto 0) := (others => '0');
    signal key        : std_logic_vector(127 downto 0) := (others => '0');
    signal ciphertext : std_logic_vector(127 downto 0);
    signal done       : std_logic;

    -- Test Vectors from Page 26 of Specification 
    constant KEY_VAL  : std_logic_vector(127 downto 0) := x"ffeeddccbbaa99887766554433221100";
    constant PT_VAL   : std_logic_vector(127 downto 0) := x"000102030405060708090a0b0c0d0e0f";
    constant CT_VAL   : std_logic_vector(127 downto 0) := x"de2bf2fd9b74aacdf1298555459494fd";
    
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: CLEFIA 
    generic map ( KEY_SIZE => 128 )
    port map (
        clk => clk, 
        rst => rst, 
        start => start, 
        mode => mode,
        plaintext => plaintext, 
        key => key, 
        ciphertext => ciphertext,
        done => done, 
        valid => open
    );

    -- Clock generation process
    clk_process: process
    begin
        clk <= '0'; 
        wait for CLK_PERIOD/2;
        clk <= '1'; 
        wait for CLK_PERIOD/2;
    end process;

    -- Main Test Stimulus Process
    stim_proc: process
    begin
        ------------------------------------------------------------
        -- 1. Initialize and Reset
        ------------------------------------------------------------
        report "Starting Simulation..." severity note;
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for CLK_PERIOD;

        ------------------------------------------------------------
        -- 2. Test ENCRYPTION
        ------------------------------------------------------------
        mode <= '0';          -- Select Encryption Mode
        key <= KEY_VAL;       -- Load Key
        plaintext <= PT_VAL;  -- Load Plaintext
        
        -- Pulse Start
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';

        -- Wait for the 'done' signal
        wait until done = '1';
        
        -- TIMING FIX: Check immediately while done is high
        wait for 1 ns; 

        if ciphertext = CT_VAL then
            report "Encryption Test: PASSED" severity note;
        else
            report "Encryption Test: FAILED" severity error;
        end if;
        
        ------------------------------------------------------------
        -- 3. Test DECRYPTION
        ------------------------------------------------------------
        wait for CLK_PERIOD * 5; -- Small gap between tests
        
        -- Reset to clear state
        rst <= '1'; 
        wait for CLK_PERIOD; 
        rst <= '0'; 
        wait for CLK_PERIOD;
        
        mode <= '1';          -- Select Decryption Mode
        key <= KEY_VAL;       -- Load Same Key
        plaintext <= CT_VAL;  -- Load Ciphertext (as input)
        
        -- Pulse Start
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';

        -- Wait for the 'done' signal
        wait until done = '1';
        
        -- TIMING FIX: Check immediately while done is high
        wait for 1 ns;

        if ciphertext = PT_VAL then
            report "Decryption Test: PASSED" severity note;
        else
            report "Decryption Test: FAILED" severity error;
        end if;

        ------------------------------------------------------------
        -- End Simulation
        ------------------------------------------------------------
        report "Simulation Completed." severity note;
        wait; 
    end process;

end behavior;
