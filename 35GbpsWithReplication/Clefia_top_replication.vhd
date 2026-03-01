library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CLEFIA_128_REPLICATION is
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
end CLEFIA_128_REPLICATION;

architecture Structural of CLEFIA_128_REPLICATION is

    component CLEFIA_128_CORE is
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

    type data_array_t is array (0 to NUM_CORES-1) of std_logic_vector(127 downto 0);

    signal start_arr    : std_logic_vector(NUM_CORES-1 downto 0);
    signal done_arr     : std_logic_vector(NUM_CORES-1 downto 0);
    signal data_out_arr : data_array_t;

    signal wr_ptr       : integer range 0 to NUM_CORES-1;

begin

    process(clk, rst)
    begin
        if rst = '1' then
            wr_ptr <= 0;
        elsif rising_edge(clk) then
            if start = '1' then
                if wr_ptr = NUM_CORES - 1 then
                    wr_ptr <= 0;
                else
                    wr_ptr <= wr_ptr + 1;
                end if;
            end if;
        end if;
    end process;

    GEN_CORES: for i in 0 to NUM_CORES-1 generate
        start_arr(i) <= start when (wr_ptr = i) else '0';

        U_CORE : CLEFIA_128_CORE
        port map (
            clk        => clk,
            rst        => rst,
            start      => start_arr(i),
            is_decrypt => is_decrypt,
            key_in     => key_in,
            data_in    => data_in,
            data_out   => data_out_arr(i),
            done       => done_arr(i)
        );
    end generate;

    process(done_arr, data_out_arr)
        variable temp_data : std_logic_vector(127 downto 0);
        variable temp_done : std_logic;
    begin
        temp_data := (others => '0');
        temp_done := '0';
        
        for i in 0 to NUM_CORES-1 loop
            if done_arr(i) = '1' then
                temp_data := data_out_arr(i);
                temp_done := '1';
            end if;
        end loop;
        
        data_out <= temp_data;
        done     <= temp_done;
    end process;

end Structural;
