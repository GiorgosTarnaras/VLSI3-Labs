library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity switch_debouncer is
    generic (
        CLK_FREQ_HZ : integer := 125_000_000;  
        DEBOUNCE_TIME_MS : integer := 10      
    );
    port (
        clk     : in  std_logic;
        reset   : in  std_logic;
        sw      : in  std_logic;  
        deb_sw  : out std_logic   
    );
end switch_debouncer;

architecture arch of switch_debouncer is
    constant COUNTER_MAX : integer := (CLK_FREQ_HZ / 1000) * DEBOUNCE_TIME_MS;
    constant COUNTER_BITS : integer := 21;
    signal counter : unsigned(COUNTER_BITS-1 downto 0) := (others => '0');
    
    type state_type is (WAIT_PRESS, COUNTING, STABLE);
    signal current_state : state_type := WAIT_PRESS;
    
 
    signal deb_sw_reg : std_logic := '1';  
    signal sw_sync : std_logic_vector(1 downto 0) := (others => '1');
    
begin
    sync_process: process(clk, reset)
    begin
        if reset = '1' then
            sw_sync <= (others => '1');
        elsif rising_edge(clk) then
            sw_sync(0) <= sw;
            sw_sync(1) <= sw_sync(0);
        end if;
    end process;
    

    debounce_process: process(clk, reset)
    begin
        if reset = '1' then
            counter <= (others => '0');
            deb_sw_reg <= '1';
            current_state <= WAIT_PRESS;
            
        elsif rising_edge(clk) then
            case current_state is
                
                when WAIT_PRESS =>
                    if sw_sync(1) = '0' then
                        counter <= (others => '0');
                        current_state <= COUNTING;
                    end if;
                    
                when COUNTING =>
                    if sw_sync(1) = '1' then
                        counter <= (others => '0');
                        current_state <= WAIT_PRESS;
                    else
                        if counter = COUNTER_MAX - 1 then
                            deb_sw_reg <= '0';
                            current_state <= STABLE;
                        else
                            counter <= counter + 1;
                        end if;
                    end if;
                    
                when STABLE =>
                    if sw_sync(1) = '1' then
                        deb_sw_reg <= '1';
                        counter <= (others => '0');
                        current_state <= WAIT_PRESS;
                    end if;
                    
            end case;
        end if;
    end process;
    
    deb_sw <= deb_sw_reg;

end arch;
