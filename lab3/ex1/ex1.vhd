library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_file is 
	port (clk, rst, wr_en: in std_logic;
		  w_addr, r_addr0, r_addr1: in std_logic_vector(1 downto 0);
		  w_data: in std_logic_vector(15 downto 0);
		  r_data0, r_data1: out std_logic_vector(15 downto 0));
end reg_file;


architecture myarch of reg_file is 
signal reg0, reg1, reg2, reg3: std_logic_vector(15 downto 0) := (others => '0');

begin 
	process(clk, rst)
    begin
		if (rst = '1') then 
			reg0 <= (others => '0');
			reg1 <= (others => '0');
			reg2 <= (others => '0');
			reg3 <= (others => '0');
		
		elsif (rising_edge(clk)) then	
			if (wr_en = '1') then
				if(w_addr = "00") then 
					reg0 <= w_data;
				elsif (w_addr = "01") then
					reg1 <= w_data;
				elsif (w_addr = "10") then
					reg2 <= w_data;
				else 
					reg3 <= w_data; 
				end if;
			end if;
		end if;

	end process;
	
	r_data0 <= reg0 when r_addr0 = "00" else
           reg1 when r_addr0 = "01" else
           reg2 when r_addr0 = "10" else
           reg3;

	r_data1 <= reg0 when r_addr1 = "00" else
           reg1 when r_addr1 = "01" else
           reg2 when r_addr1 = "10" else
           reg3;
end myarch;