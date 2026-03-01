library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_CLEFIA_128_REPLICATION is
end tb_CLEFIA_128_REPLICATION;

architecture Behavioral of tb_CLEFIA_128_REPLICATION is

    -- DUT Component Declaration
    component CLEFIA_128_REPLICATION is
        Generic (
            NUM_CORES : integer := 31 
        );
        Port (
            clk        : in  std_logic;
            rst        : in  std_logic;
            start      : in  std_logic;
            is_decrypt : in  std_logic;
            key_in     : in  std_logic_vector (127 downto 0);
            data_in    : in  std_logic_vector (127 downto 0);
            data_out   : out std_logic_vector (127 downto 0);
            done       : out std_logic
        );
    end component;

    -- Constants
    constant C_NUM_CORES : integer := 31;
    constant CLK_PERIOD  : time    := 4 ns; -- Updated clock to 4ns

    -- CLEFIA Test Vectors
    constant TEST_KEY_VAL : std_logic_vector(127 downto 0) := x"ffeeddccbbaa99887766554433221100";
    constant TEST_PT_VAL  : std_logic_vector(127 downto 0) := x"000102030405060708090a0b0c0d0e0f";
    constant TEST_CT_VAL  : std_logic_vector(127 downto 0) := x"de2bf2fd9b74aacdf1298555459494fd";

    -- Signals to connect to DUT
    signal tb_clk        : std_logic := '0';
    signal tb_rst        : std_logic := '0';
    signal tb_start      : std_logic := '0';
    signal tb_is_decrypt : std_logic := '0';
    signal tb_key_in     : std_logic_vector(127 downto 0) := (others => '0');
    signal tb_data_in    : std_logic_vector(127 downto 0) := (others => '0');
    signal tb_data_out   : std_logic_vector(127 downto 0);
    signal tb_done       : std_logic;

begin

    -- Instantiate the Device Under Test (DUT)
    UUT: CLEFIA_128_REPLICATION
        generic map (
            NUM_CORES => C_NUM_CORES
        )
        port map (
            clk        => tb_clk,
            rst        => tb_rst,
            start      => tb_start,
            is_decrypt => tb_is_decrypt,
            key_in     => tb_key_in,
            data_in    => tb_data_in,
            data_out   => tb_data_out,
            done       => tb_done
        );

    -- Clock Generation Process (4 ns period -> 250 MHz)
    clk_process : process
    begin
        tb_clk <= '0';
        wait for CLK_PERIOD / 2;
        tb_clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Stimulus Process
    stimulus_process : process
    begin
        -- 1. Initialize and assert reset
        tb_rst <= '1';
        tb_start <= '0';
        tb_is_decrypt <= '0';
        tb_key_in <= (others => '0');
        tb_data_in <= (others => '0');
        
        wait for CLK_PERIOD * 5;
        
        -- De-assert reset
        tb_rst <= '0';
        wait until rising_edge(tb_clk);

        -- 2. Stream 35 back-to-back requests (alternating Encrypt/Decrypt)
        for i in 0 to 34 loop
            tb_start  <= '1';
            tb_key_in <= TEST_KEY_VAL; -- Key is constant for all operations
            
            if (i mod 2) = 0 then
                -- Even cycles: Encrypt the Plaintext
                tb_is_decrypt <= '0';
                tb_data_in    <= TEST_PT_VAL;
            else
                -- Odd cycles: Decrypt the Ciphertext
                tb_is_decrypt <= '1';
                tb_data_in    <= TEST_CT_VAL;
            end if;
            
            wait until rising_edge(tb_clk);
        end loop;

        -- 3. Stop sending inputs
        tb_start      <= '0';
        tb_is_decrypt <= '0';
        tb_data_in    <= (others => '0');

        -- 4. Wait for the pipeline to drain
        -- You will see alternating TEST_CT_VAL and TEST_PT_VAL pop out of data_out 
        -- once the done signal goes high.
        wait for CLK_PERIOD * 500;

        -- End simulation
        std.env.stop;
        wait;
    end process;

    -- Optional: Console Monitor Process
    monitor_process : process
        variable out_count : integer := 0;
    begin
        wait until rising_edge(tb_clk);
        if tb_done = '1' then
            out_count := out_count + 1;
            report "Output #" & integer'image(out_count) & " ready at " & time'image(now);
        end if;
    end process;

end Behavioral;
