library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debouncer_tb is
end debouncer_tb;

architecture Behavioral of debouncer_tb is

    component debouncer
        Port ( 
            clk      : in  std_logic;
            reset    : in  std_logic;
            btn_in   : in  std_logic;
            btn_out  : out std_logic
        );
    end component;

    signal clk_tb     : std_logic := '0';
    signal reset_tb   : std_logic := '0';
    signal btn_in_tb  : std_logic := '0';
    signal btn_out_tb : std_logic;

    constant clk_period : time := 10 ns;

begin

    uut: debouncer Port map (
          clk     => clk_tb,
          reset   => reset_tb,
          btn_in  => btn_in_tb,
          btn_out => btn_out_tb
        );

    clk_process : process
    begin
        clk_tb <= '0';
        wait for clk_period/2;
        clk_tb <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
    begin		
        -- Reset inicial
        reset_tb <= '1';
        wait for 20 ns;
        reset_tb <= '0';
        wait for 20 ns;

        -- SIMULACIÓN DE REBOTES
        btn_in_tb <= '1'; wait for 20 ns;
        btn_in_tb <= '0'; wait for 15 ns;
        btn_in_tb <= '1'; wait for 30 ns;
        btn_in_tb <= '0'; wait for 10 ns;
        
        -- PULSACIÓN ESTABLE
        btn_in_tb <= '1';
        wait for 15 ms;

        -- SOLTAMOS EL BOTÓN
        btn_in_tb <= '0'; wait for 10 ns;
        btn_in_tb <= '1'; wait for 20 ns;
        btn_in_tb <= '0';
        
        wait for 1 ms;
        
        assert false report "Simulación terminada con éxito" severity note;
        wait;
    end process;

end Behavioral;