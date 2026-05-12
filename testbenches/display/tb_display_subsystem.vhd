library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_display_subsystem is
end tb_display_subsystem;

architecture Behavioral of tb_display_subsystem is

    component display_subsystem
        Port (
            clk         : in    std_logic;
            reset       : in    std_logic;
            cpu_opcode  : in  std_logic_vector(6 downto 0);
            cpu_reg     : in  std_logic_vector(4 downto 0);
            cpu_val     : in  std_logic_vector(15 downto 0);
            sda         : inout std_logic;
            scl         : inout std_logic
        );
    end component;

    -- Señales de estímulo
    signal clk          : std_logic := '0';
    signal reset        : std_logic := '1';
    signal cpu_opcode   : std_logic_vector(6 downto 0) := "0110011"; -- x33
    signal cpu_reg      : std_logic_vector(4 downto 0) := "01010";   -- x0A
    signal cpu_val      : std_logic_vector(15 downto 0) := x"ABCD";
    
    -- Señales inout necesitan inicializarse en 'Z' o 'H' (Pull-up virtual)
    signal sda          : std_logic := 'H'; 
    signal scl          : std_logic := 'H';

    constant clk_period : time := 10 ns;

begin

    uut: display_subsystem port map (
        clk        => clk,
        reset      => reset,
        cpu_opcode => cpu_opcode,
        cpu_reg    => cpu_reg,
        cpu_val    => cpu_val,
        sda        => sda,
        scl        => scl
    );

    -- Generación de reloj
    clk_process : process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    -- Proceso principal
    stim_proc: process
    begin		
        -- Aplicamos reset
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        
        -- Simulamos que la CPU está calculando una instrucción
        cpu_opcode <= "0110011";
        cpu_reg    <= "01010";
        cpu_val    <= x"ABCD";

        report "Subsistema activo. Esperando actividad I2C...";
        
        -- Como el I2C es un protocolo lento, tenemos que esperar 
        -- bastante tiempo simulado para ver las transferencias completas.
        -- Ejecuta la simulación por unos 2 o 3 milisegundos (ms).
        wait for 2 ms;
        
        -- Cambiamos los datos para ver si responde
        cpu_opcode <= "0010011"; -- x13
        cpu_reg    <= "00001";   -- x01
        cpu_val    <= x"9999";
        
        wait for 2 ms;

        assert false report "Fin de la simulacion" severity failure;
    end process;

end Behavioral;