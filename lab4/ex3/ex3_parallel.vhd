library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mean_value is 
    port (clk, rst: in std_logic;
          x0, x1, x2, x3, x4, x5, x6, x7: in std_logic_vector(15 downto 0);
          y: out std_logic_vector(15 downto 0));
end mean_value;

architecture parallel of mean_value is 
    type type_1Dx1D is array (0 to 7) of std_logic_vector(18 downto 0);
    signal parallel_in: type_1Dx1D;
    signal serial_out: std_logic_vector(18 downto 0);
begin 
    process(clk, rst)
    variable add1, add2, add3, add4, add5, add6, add7: unsigned(18 downto 0);
    begin
        if (rst = '1') then
            parallel_in <= (others => (others => '0'));
            serial_out <= (others => '0');
            y <= (others => '0');
        elsif (rising_edge(clk)) then 
            parallel_in <= ("000"&x7, "000"&x6, "000"&x5, "000"&x4, "000"&x3, "000"&x2, "000"&x1, "000"&x0);
            add1 := unsigned(parallel_in(0)) + unsigned(parallel_in(1));
            add2 := unsigned(parallel_in(2)) + unsigned(parallel_in(3));
            add3 := unsigned(parallel_in(4)) + unsigned(parallel_in(5));
            add4 := unsigned(parallel_in(6)) + unsigned(parallel_in(7));
            add5 := add1+add2;
            add6 := add3+add4;
            add7 := add5+add6;
            serial_out <= std_logic_vector(add7);
        	y <= serial_out(18 downto 3);
        end if;
    end process;
    
end parallel;