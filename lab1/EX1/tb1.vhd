library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;  

entity tb1 is
end tb1;

architecture testbench of tb1 is
    
    -- Signals
    signal row1 : std_logic_vector(3 downto 0);
    signal row2 : std_logic_vector(3 downto 0);
    signal row3 : std_logic_vector(3 downto 0);
    
    -- Control signals
    signal ctrl1_R, ctrl2, ctrl3 : integer range 1 to 3;
    signal ctrl1_C, ctrl4 : integer range 0 to 3;

    -- Output slices
    signal slice1 : std_logic;
    signal slice2 : std_logic_vector(1 downto 0);
    signal slice3 : std_logic_vector(3 downto 0);
    signal slice4 : std_logic_vector(2 downto 0);

    -- DUT Declaration
    component array_slices_x1D is   
        port(
            row1    : in  std_logic_vector(3 downto 0);
            row2    : in  std_logic_vector(3 downto 0);
            row3    : in  std_logic_vector(3 downto 0);
            ctrl1_R : in  integer range 1 to 3;
            ctrl1_C : in  integer range 0 to 3;
            ctrl2   : in  integer range 1 to 3;
            ctrl3   : in  integer range 1 to 3;
            ctrl4   : in  integer range 0 to 3;
            slice1  : out std_logic;
            slice2  : out std_logic_vector(1 downto 0);
            slice3  : out std_logic_vector(3 downto 0);
            slice4  : out std_logic_vector(2 downto 0)
        );
    end component;

begin

    -- Instantiate Unit Under Test (UUT)
    UUT: array_slices_x1D
        port map (
            row1    => row1,
            row2    => row2,
            row3    => row3,
            ctrl1_R => ctrl1_R,
            ctrl1_C => ctrl1_C,
            ctrl2   => ctrl2,
            ctrl3   => ctrl3,
            ctrl4   => ctrl4,
            slice1  => slice1,
            slice2  => slice2,
            slice3  => slice3,
            slice4  => slice4
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize inputs
        row1 <= "0011";
        row2 <= "1011";
        row3 <= "1101";
        ctrl1_R <= 1;
        ctrl1_C <= 3;
        ctrl2 <= 2;
        ctrl3 <= 3;
        ctrl4 <= 0;

        wait for 10 ns;
        
        ctrl4 <= 1;

        wait for 10 ns;
        
        ctrl1_R <= 1;
        ctrl1_C <= 3;

        wait for 10 ns;
        wait;
    end process;

end testbench;
