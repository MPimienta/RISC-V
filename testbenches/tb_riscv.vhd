library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity riscv_tb is
end riscv_tb;

architecture behavior of riscv_tb is

    -- Declaración del componente principal (El Top-Level)
    component riscv
        Port ( 
            btn_clk     : in std_logic;
            clk         : in std_logic;
            btn_reset   : in std_logic;
            swt         : in std_logic_vector (7 downto 0);
            led         : out std_logic_vector (7 downto 0);
            seg         : out std_logic_vector (6 downto 0);
            dp          : out std_logic;
            an          : out std_logic_vector (3 downto 0)
        );
    end component;

    -- Señales internas para conectar al componente
    signal btn_clk   : std_logic := '0';
    signal clk       : std_logic := '0';
    signal btn_reset : std_logic := '0';
    signal swt       : std_logic_vector (7 downto 0) := (others => '0');
    
    signal led       : std_logic_vector (7 downto 0);
    signal seg       : std_logic_vector (6 downto 0);
    signal dp        : std_logic;
    signal an        : std_logic_vector (3 downto 0);

    -- Reloj principal a 100 MHz (Periodo de 10 ns)
    constant clk_period : time := 10 ns;

begin

    -- Instanciación de tu CPU
    uut: riscv Port map (
        btn_clk => btn_clk,
        clk => clk,
        btn_reset => btn_reset,
        swt => swt,
        led => led,
        seg => seg,
        dp => dp,
        an => an
    );

    -- Generador del reloj continuo de la placa
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Proceso que emula el comportamiento humano pulsando los botones
    stim_proc: process
    begin
        -- 1. Encendemos la placa y mantenemos presionado el Reset
        btn_reset <= '1';
        wait for 100 ns;
        
        -- Soltamos el Reset
        btn_reset <= '0';
        wait for 100 ns;

        -- 2. Ponemos unos valores aleatorios en los interruptores físicos
        swt <= x"A5"; 

        -- 3. Empezamos a pulsar el botón de reloj manual ('btn_clk')
        -- Un bucle de 50 pulsaciones para ejecutar bastantes instrucciones
        for i in 1 to 50 loop
            
            -- Pulsamos el botón (Dedo abajo)
            btn_clk <= '1';
            
            -- Esperamos 200 ns (Suficiente para superar el 'count = 10' del debouncer en simulación)
            wait for 200 ns; 
            
            -- Soltamos el botón (Dedo arriba)
            btn_clk <= '0';
            
            -- Esperamos un tiempo muerto antes del siguiente clic
            wait for 200 ns;
            
        end loop;

        -- Terminamos la simulación
        wait;
    end process;

end behavior;