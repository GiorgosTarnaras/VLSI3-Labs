library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity arbiter is 
    port (clk, rst: in std_logic;
          r: in std_logic_vector(1 downto 0);
          g: out std_logic_vector(1 downto 0));
end arbiter;

architecture fsm of arbiter is 
type state_type is (waitr, grant0, grant1);
signal pr_state, nx_state: state_type;
signal r_in: std_logic_vector(1 downto 0);
signal priority: std_logic;

begin 
    
    REGS: process(clk)
    begin
        if rising_edge(clk) then 
            if rst = '1' then
                pr_state <= waitr;
                r_in <= "00";
                priority <= '1';
            else 
                pr_state <= nx_state;
                r_in <= r;

                case pr_state is  
                when waitr => 
                    priority <= priority;
                when grant0 => 
                    priority <= '1';
                when grant1 =>  
                    priority <= '0';
                end case;

            end if;
        end if;
    end process REGS;

    FSM_LOGIC: process(pr_state, r_in, priority)
    begin 
        case pr_state is
            when waitr => 
                if r_in = "00" then nx_state <= waitr;
                elsif r_in = "01" then nx_state <= grant0;
                elsif  r_in = "10" then nx_state <= grant1;
                elsif r_in = "11" and priority = '1' then nx_state <= grant1;
                else nx_state <= grant0; 
                end if;
            when grant0 => 
                if r_in(0) = '1' then nx_state <= grant0; 
                else nx_state <= waitr;
                end if;
              
            when grant1 =>  
                if r_in(1) = '1' then nx_state <= grant1; 
                else nx_state <= waitr;
                end if;
                
        end case;
    end process FSM_LOGIC;

    OUTPUT_LOGIC: process(pr_state)
    begin 
        case pr_state is  
        when waitr => 
            g <= "00";
        when grant0 => 
            g <= "01";
        when grant1 =>  
            g <= "10";
        end case;
        
    end process OUTPUT_LOGIC;


end fsm;