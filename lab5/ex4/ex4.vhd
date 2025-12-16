library ieee;
use ieee.std_logic_1164.all;

entity fsm_counter is
    port (
        clk   : in  std_logic;
        rst   : in  std_logic; 
        en    : in  std_logic; 
        u_d   : in  std_logic; 
        dout  : out std_logic_vector(2 downto 0)
    );
end fsm_counter;

architecture behavioral of fsm_counter is

    type state_type is (A, B, C, D, E, F);
    signal current_state, next_state : state_type;  
begin

    state_reg: process(clk, rst)
    begin
        if rst = '1' then
            current_state <= A; 
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;
    
    next_state_logic: process(current_state, en, u_d)
    begin
        if en = '1' then
            case current_state is
                when A => 
                    if u_d = '1' then 
                        next_state <= B;  
                    else              
                        next_state <= E;  
                    end if;
                    
                when B => 
                    if u_d = '1' then 
                        next_state <= C;  
                    else              
                        next_state <= F;  
                    end if;
                    
                when C => 
                    if u_d = '1' then 
                        next_state <= D;  
                    else              
                        next_state <= A;  
                    end if;
                    
                when D => 
                    if u_d = '1' then 
                        next_state <= E;  
                    else              
                        next_state <= B; 
                    end if;
                    
                when E => 
                    if u_d = '1' then 
                        next_state <= F;  
                    else              
                        next_state <= C;  
                    end if;
                    
                when F => 
                    if u_d = '1' then 
                        next_state <= A;  
                    else              
                        next_state <= D;  
                    end if;
            end case;
        else next_state <= current_state;
        end if;
    end process;
   
        
    output_p:process(current_state)
    begin
        case current_state is
        when A=> dout<="000";
        when B=> dout<="001";
        when C=> dout<="010";
        when D=> dout<="011";
        when E=> dout<="100";
        when F=> dout<="101";
    end case;
    end process;
    
    
    
end behavioral;
