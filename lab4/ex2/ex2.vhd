library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity merge_sort is 
    port (clk, rst, en: in std_logic;
          In_a, In_b, In_c, In_d: in std_logic_vector(15 downto 0);
          Sorted_Out_a, Sorted_Out_b, Sorted_Out_c, Sorted_Out_d: out std_logic_vector(15 downto 0));
end merge_sort;

architecture myarch of merge_sort is 
    signal RegA, RegB, RegC, RegD: std_logic_vector(15 downto 0);
    signal MiddleA, MiddleB, MiddleC, MiddleD: std_logic_vector(15 downto 0);
begin 
    step1: process(clk, rst)
    begin
        if (rst = '1') then
            RegA <= (others=>'0');
            RegB <= (others=>'0');
            RegC <= (others=>'0');
            RegD <= (others=>'0');
        elsif (rising_edge(clk) and en = '1') then 
        	RegA <= In_a;
            RegB <= In_b;
            RegC <= In_c;
            RegD <= In_d;
        end if;
    end process step1;

    step2: process(clk, rst)
    begin
    
        if(rst = '1') then 
            MiddleA <= (others=>'0');
            MiddleB <= (others=>'0');
            MiddleC <= (others=>'0');
            MiddleD <= (others=>'0');
            
        elsif (rising_edge(clk)) then 
            if unsigned(RegA) > unsigned(RegB) then 
                MiddleA <= RegB;
                MiddleB <= RegA;
            else 
                MiddleA <= RegA;
                MiddleB <= RegB;
            end if;

            if unsigned(RegC) > unsigned(RegD) then 
                MiddleC <= RegD;
                MiddleD <= RegC;
            else 
                MiddleC <= RegC;
                MiddleD <= RegD;
            end if;

        end if;
    end process step2;

    step3: process(clk, rst)
    variable temp1, temp2: std_logic_vector(15 downto 0);
    begin
        if (rst = '1') then 
            Sorted_Out_a <= (others=>'0');
            Sorted_Out_b <= (others=>'0');
            Sorted_Out_c <= (others=>'0');
            Sorted_Out_d <= (others=>'0');
        elsif (rising_edge(clk)) then 
            if unsigned(MiddleA) < unsigned(MiddleC) then 
                Sorted_Out_a <= MiddleA;
                temp1 := MiddleC;
            else 
                Sorted_Out_a <= MiddleC;
                temp1 := MiddleA;
            end if;

            if unsigned(MiddleB) < unsigned(MiddleD) then 
                Sorted_Out_d <= MiddleD;
                temp2 := MiddleB;
            else 
                Sorted_Out_d <= MiddleB;
                temp2 := MiddleD;
            end if;

            if unsigned(temp1) > unsigned(temp2) then
                Sorted_Out_b <= temp2; 
                Sorted_Out_c <= temp1;
            else 
                Sorted_Out_b <= temp1;
                Sorted_Out_c <= temp2;
            end if;
        end if;

    end process step3;
end myarch;