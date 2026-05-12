library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_keypad_controller is
end tb_keypad_controller;

architecture Behavioral of tb_keypad_controller is
    component keypad_controller
        Port (
            clk         : in  STD_LOGIC;
            reset       : in  STD_LOGIC;
            keypad_col  : in  STD_LOGIC_VECTOR (3 downto 0);
            keypad_row  : out STD_LOGIC_VECTOR (3 downto 0);
            data_out    : out STD_LOGIC_VECTOR (15 downto 0)
        );
    end component;
    signal clk         : std_logic := '0';
    signal reset       : std_logic := '0';
    signal keypad_col  : std_logic_vector(3 downto 0) := "1111"; 
    signal keypad_row  : std_logic_vector(3 downto 0);
    signal data_out    : std_logic_vector(15 downto 0);
    constant clk_period : time := 10 ns;

begin
    uut: keypad_controller port map (
        clk => clk,
        reset => reset,
        keypad_col => keypad_col,
        keypad_row => keypad_row,
        data_out => data_out
    );

    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
    begin
        reset <= '1';
        wait for 100 ns;	
        reset <= '0';

        wait for 5 ms;

        wait until keypad_row = "1101"; 

        wait for 10 ms; 

        keypad_col <= "1111"; 

        wait for 5 ms;

        wait until keypad_row = "1110"; 
        keypad_col <= "0111"; 
        wait for 15 ms;      
        keypad_col <= "1111"; 
        wait for 5 ms;
        wait until keypad_row = "0111"; 
        keypad_col <= "1011";
        wait for 8 ms;
        keypad_col <= "1111"; 
        wait;
    end process;

end Behavioral;