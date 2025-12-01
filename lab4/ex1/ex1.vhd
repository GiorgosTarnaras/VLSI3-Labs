library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_mux is
    port (
        clk     : in  std_logic;
        reset   : in  std_logic;  
        in0     : in  std_logic_vector(7 downto 0);
        in1     : in  std_logic_vector(7 downto 0);
        in2     : in  std_logic_vector(7 downto 0);
        in3     : in  std_logic_vector(7 downto 0);
        an      : out std_logic_vector(3 downto 0);  
        sseg    : out std_logic_vector(7 downto 0)
    );
end led_mux;

architecture arch of led_mux is

    signal counter : unsigned(13 downto 0);
    signal display_sel : unsigned(1 downto 0);
    
begin
	process(clk, reset)
    begin
        if reset = '1' then
            counter <= (others => '0');
            display_sel <= "00";
        elsif rising_edge(clk) then
            counter <= counter + 1;
            if counter = 0 then
                display_sel <= display_sel + 1;
            end if;
        end if;
    end process;
    
    with display_sel select
        sseg <= in0 when "00",
                in1 when "01",
                in2 when "10",
                in3 when others;
    
    with display_sel select
        an <= "1110" when "00",  
              "1101" when "01",  
              "1011" when "10",  
              "0111" when others; 

end arch;
