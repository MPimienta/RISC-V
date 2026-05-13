library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_top_level is
-- Un testbench no tiene puertos
end tb_top_level;

architecture Behavioral of tb_top_level is

    -- 1. Declaración del componente Top Level
    component top_level
        Port ( 
            clk         : in std_logic;
            btn_reset   : in std_logic;
            btn_clk     : in std_logic;
            swt         : in std_logic_vector (15 downto 0);
            led         : out std_logic_vector (15 downto 0);
            seg         : out std_logic_vector (6 downto 0);
            dp          : out std_logic;
            an          : out std_logic_vector (3 downto 0);
            keypad_col  : in std_logic_vector(3 downto 0);
            keypad_row  : out std_logic_vector(3 downto 0);
            sda         : inout std_logic;
            scl         : inout std_logic
        );
    end component;

    -- 2. Señales de estímulo e interconexión
    signal clk        : std_logic := '0';
    signal btn_reset  : std_logic := '0';
    signal btn_clk    : std_logic := '0';
    signal swt        : std_logic_vector (15 downto 0) := (others => '0');
    signal led        : std_logic_vector (15 downto 0);
    signal seg        : std_logic_vector (6 downto 0);
    signal dp         : std_logic;
    signal an         : std_logic_vector (3 downto 0);
    
    -- Teclado
    signal keypad_col : std_logic_vector(3 downto 0) := "1111"; -- Pull-up por defecto
    signal keypad_row : std_logic_vector(3 downto 0);

    -- I2C (Pull-ups simulados con 'H')
    signal sda : std_logic := 'H';
    signal scl : std_logic := 'H';

    constant clk_period : time := 10 ns; -- 100 MHz

begin

    -- 3. Instanciación del Top Level
    uut: top_level Port map (
        clk         => clk,
        btn_reset   => btn_reset,
        btn_clk     => btn_clk,
        swt         => swt,
        led         => led,
        seg         => seg,
        dp          => dp,
        an          => an,
        keypad_col  => keypad_col,
        keypad_row  => keypad_row,
        sda         => sda,
        scl         => scl
    );

    -- 4. Generador del reloj principal (100 MHz)
    clk_process :process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    -- 5. Proceso principal de estímulos (El "Usuario Humano")
    stim_proc: process
    begin
        -- Estado inicial de interruptores
        swt <= x"0054"; -- Valor de ejemplo
        
        -- RESET GENERAL DEL SISTEMA
        btn_reset <= '1';
        wait for 100 ns;
        btn_reset <= '0';
        wait for 500 ns;
        
        -- Dejamos que los controladores automáticos (LCD Power Up, Keypad Scan) arranquen
        wait for 2000 ns;

        -------------------------------------------------------------
        -- ACCIÓN 1: SIMULAR PULSACIÓN EN EL TECLADO (Tecla '5')
        -- Fila 1 (bit 1) y Columna 1 (bit 1) -> "1101"
        -------------------------------------------------------------
        -- Esperamos a que el escáner del teclado pase por la Fila 1
        wait until keypad_row = "1101";
        
        -- ¡Pulsamos el botón físico!
        keypad_col <= "1101";

        -------------------------------------------------------------
        -- ACCIÓN 2: EJECUTAR LA CPU (Reloj manual)
        -------------------------------------------------------------
        -- Avanzamos la CPU 20 ciclos para que lea el teclado,
        -- guarde el dato, y mande los valores al display_manager.
        for i in 1 to 20 loop
            btn_clk <= '1';
            wait for 50 ns; 
            btn_clk <= '0';
            wait for 50 ns;
        end loop;
        
        -------------------------------------------------------------
        -- ACCIÓN 3: SOLTAR LA TECLA Y VER EL I2C TRABAJAR
        -------------------------------------------------------------
        -- Soltamos el botón del teclado
        keypad_col <= "1111";
        wait for 200 ns;
        
        -- Seguimos dándole al reloj de la CPU de vez en cuando, 
        -- mientras observamos en la simulación cómo el controlador LCD 
        -- empieza a mover las señales SDA y SCL para pintar en pantalla.
        for i in 1 to 50 loop
            btn_clk <= '1';
            wait for 100 ns; 
            btn_clk <= '0';
            wait for 100 ns;
            
            -- El I2C y el Display trabajan con 'clk' automático, no necesitan 'btn_clk', 
            -- pero la CPU necesita btn_clk para seguir su bucle.
        end loop;

        -- Fin de la prueba
        wait;
    end process;

end Behavioral;