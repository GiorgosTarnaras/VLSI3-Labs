library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FSM_timer is 
    generic(T1: natural := 2;
            T2: natural := 4);
    port (clk: in std_logic;
          x: in std_logic;
          y: out std_logic);
end FSM_timer;

architecture fsm of FSM_timer is 
type state_type is (A, B, C);
signal pr_state, nx_state: state_type;
signal x_in: std_logic ;
signal t: natural range 0 to T2 ;

begin 
    
    process(clk)
    begin
        if rising_edge(clk) then                
            pr_state <= nx_state;
            x_in <= x;
        end if;
    end process;

    process(clk)
    begin 
        if rising_edge(clk) then                   
            if pr_state /= nx_state then 
                t <= 0;
            elsif t /= T2 then 
                t <= t + 1;
            end if;
        end if;
    end process;


    process(pr_state, x_in, t)
    begin 
        case pr_state is
            when A => 
                if x_in = '1' then nx_state <= B;
                else nx_state <= A;
                end if;
            when B => 
                if (x_in = '0' and t < T1) or (x_in /= '0' and t < T2) then nx_state <= B;
                elsif t = T2 then nx_state <= A;
                elsif x_in = '0' and t = T1 then nx_state <= C;
                else nx_state <= B;
                end if; 
            when C =>  
                if t = T2 then nx_state <= A;
                else nx_state <= C;
                end if;
        end case;
    end process;




    process(pr_state)
    begin 
        case pr_state is  
        when A => 
            y <= '0';
        when B => 
            y <= '0';
        when C =>  
            y <= '1';
        end case;
        
    end process;


end fsm;