library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity binary_to_bcd is
    Port ( binary_in : in  std_logic_vector(11 downto 0);
           bcd_out   : out std_logic_vector(15 downto 0));
end binary_to_bcd;

architecture arch of binary_to_bcd is


    constant NUM_STAGES : integer := 12;

    type t_stage_vector is array (0 to NUM_STAGES) of std_logic_vector(27 downto 0);
    signal stages : t_stage_vector;

begin

    stages(0) <= (27 downto 12 => '0') & binary_in;



    g_stages : for i in 0 to NUM_STAGES - 1 generate
    

        signal after_add : std_logic_vector(27 downto 0);
        signal stage_out : std_logic_vector(27 downto 0);
        
    begin


        after_add(27 downto 24) <= std_logic_vector(unsigned(stages(i)(27 downto 24)) + 3) 
                                   when unsigned(stages(i)(27 downto 24)) > 4 
                                   else stages(i)(27 downto 24);
                                   
 
        after_add(23 downto 20) <= std_logic_vector(unsigned(stages(i)(23 downto 20)) + 3) 
                                   when unsigned(stages(i)(23 downto 20)) > 4 
                                   else stages(i)(23 downto 20);


        after_add(19 downto 16) <= std_logic_vector(unsigned(stages(i)(19 downto 16)) + 3) 
                                   when unsigned(stages(i)(19 downto 16)) > 4 
                                   else stages(i)(19 downto 16);

        after_add(15 downto 12) <= std_logic_vector(unsigned(stages(i)(15 downto 12)) + 3) 
                                   when unsigned(stages(i)(15 downto 12)) > 4 
                                   else stages(i)(15 downto 12);


        after_add(11 downto 0) <= stages(i)(11 downto 0);



        stage_out <= after_add(26 downto 0) & '0';
        

        stages(i+1) <= stage_out;

    end generate g_stages;



    bcd_out <= stages(NUM_STAGES)(27 downto 12);

end architecture arch;
