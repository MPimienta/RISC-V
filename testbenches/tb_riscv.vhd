library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity riscv_tb is
end riscv_tb;

architecture behavior of riscv_tb is

    -- Declaración del Top Level
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

    -- Señales internas
    signal btn_clk   : std_logic := '0';
    signal clk       : std_logic := '0';
    signal btn_reset : std_logic := '0';
    signal swt       : std_logic_vector (7 downto 0) := (others => '0');
    
    signal led       : std_logic_vector (7 downto 0);
    signal seg       : std_logic_vector (6 downto 0);
    signal dp        : std_logic;
    signal an        : std_logic_vector (3 downto 0);

    -- Reloj de 100 MHz (Periodo de 10 ns)
    constant clk_period : time := 10 ns;

begin

    -- Instanciación de la CPU completa
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

    -- Proceso oscilador del Reloj de la Basys 3
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Proceso de estímulos (El "Dedo humano")
    stim_proc: process
    begin
        -- 1. Mantenemos pulsado el botón de Reset general
        btn_reset <= '1';
        wait for 50 ns;
        btn_reset <= '0';
        wait for 50 ns;

        -- 2. Configuramos unos switches de ejemplo (por si el código los lee en 0xE0)
        swt <= x"A5"; 

        -- 3. Emulamos al usuario pulsando el botón "Step" (btn_clk) repetidamente.
        -- 50 toques son suficientes para ejecutar aprox. 10 instrucciones (5 ciclos por inst.)
        for i in 1 to 50 loop
            -- Pulsamos el botón
            btn_clk <= '1';
            
            -- Esperamos tiempo suficiente para superar el debouncer de simulación (count=10)
            wait for 200 ns; 
            
            -- Soltamos el botón
            btn_clk <= '0';
            
            -- Tiempo muerto hasta el siguiente click
            wait for 200 ns;
        end loop;

        -- Fin de la simulación
        wait;
    end process;

end behavior;