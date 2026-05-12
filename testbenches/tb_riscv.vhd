library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity riscv_tb is
end riscv_tb;

architecture behavior of riscv_tb is

    component riscv
        Port ( 
            btn_clk    : in std_logic;
            clk        : in std_logic;
            btn_reset  : in std_logic;
            swt        : in std_logic_vector (15 downto 0);
            led        : out std_logic_vector (15 downto 0);
            seg        : out std_logic_vector (6 downto 0);
            dp         : out std_logic;
            an         : out std_logic_vector (3 downto 0);
            keypad_col : in std_logic_vector(3 downto 0);
            keypad_row : out std_logic_vector(3 downto 0);
            -- NUEVOS PINES I2C DEL LCD
            lcd_sda    : inout std_logic;
            lcd_scl    : inout std_logic
        );
    end component;

    signal btn_clk    : std_logic := '0';
    signal clk        : std_logic := '0';
    signal btn_reset  : std_logic := '0';
    signal swt        : std_logic_vector (15 downto 0) := (others => '0');
    signal led        : std_logic_vector (15 downto 0);
    signal seg        : std_logic_vector (6 downto 0);
    signal dp         : std_logic;
    signal an         : std_logic_vector (3 downto 0);
    signal keypad_col : std_logic_vector(3 downto 0) := "1111";
    signal keypad_row : std_logic_vector(3 downto 0);
    
    -- Señales para el LCD
    signal lcd_sda    : std_logic;
    signal lcd_scl    : std_logic;

    constant clk_period : time := 10 ns; -- Reloj de 100 MHz
    
    -- Señales de control para simular la pulsación humana del keypad
    signal sim_key_row : std_logic_vector(3 downto 0) := "1111";
    signal sim_key_col : std_logic_vector(3 downto 0) := "1111";

begin

    -- El bus I2C funciona con lógica de colector abierto. 
    -- Estas son las Resistencias Pull-Up virtuales para la simulación.
    lcd_sda <= 'H';
    lcd_scl <= 'H';

    uut: riscv Port map (
        btn_clk    => btn_clk, 
        clk        => clk, 
        btn_reset  => btn_reset,
        swt        => swt, 
        led        => led, 
        seg        => seg, 
        dp         => dp, 
        an         => an,
        keypad_col => keypad_col, 
        keypad_row => keypad_row,
        lcd_sda    => lcd_sda,
        lcd_scl    => lcd_scl
    );

    -- Generador de Reloj del Sistema (100 MHz)
    clk_process :process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;
    
    -- Generador de Reloj de la CPU
    -- A diferencia de tu versión anterior, aquí dejamos la CPU corriendo
    -- continuamente como un reloj real para que ejecute el programa entero.
    btn_clk_process :process
    begin
        btn_clk <= '0'; wait for 150 ns;
        btn_clk <= '1'; wait for 150 ns;
    end process;

    -- LÓGICA AUTOMÁTICA DEL KEYPAD
    -- Al ser matricial, solo bajamos la columna si la CPU está escaneando la fila correcta
    keypad_col <= sim_key_col when (keypad_row = sim_key_row) else "1111";

    stim_proc: process
    begin
        -- 1. Reset inicial
        btn_reset <= '1';
        wait for 100 ns;
        btn_reset <= '0';
        
        -- =========================================================================
        -- ¡ATENCIÓN! NOTA DE SIMULACIÓN:
        -- Tu lcd_controller.vhd espera 50 milisegundos reales al encender.
        -- En simulación, 50 ms = 5.000.000 de ciclos de reloj (tardará horas en tu PC).
        -- Para que esta simulación termine rápido, ve a 'lcd_controller.vhd' y 
        -- cambia temporalmente la constante:
        -- constant MS_50 : integer := 500;  <-- Usa un valor bajo solo para simular
        -- =========================================================================
        
        -- Esperamos a que pase el tiempo de inicialización del LCD
        wait for 6ms; 

        -- =========================================================================
        -- OPERACIÓN DE PRUEBA: 3 + 2 =
        -- =========================================================================
        
        -- Pulsar tecla '3' (Fila 0: "1110", Columna 2: "1011")
        sim_key_row <= "1110"; sim_key_col <= "1011";
        wait for 100 us; -- Mantenemos pulsado 2 milisegundos
        sim_key_row <= "1111"; sim_key_col <= "1111"; -- Soltar
        wait for 100 us; -- Tiempo para que la CPU lo lea, lo dibuje y vuelva al bucle
        
        -- Pulsar tecla 'A' / Suma (Fila 0: "1110", Columna 3: "0111")
        sim_key_row <= "1110"; sim_key_col <= "0111";
        wait for 100 us;
        sim_key_row <= "1111"; sim_key_col <= "1111"; -- Soltar
        wait for 100 us;
        
        -- Pulsar tecla '2' (Fila 0: "1110", Columna 1: "1101")
        sim_key_row <= "1110"; sim_key_col <= "1101";
        wait for 100 us;
        sim_key_row <= "1111"; sim_key_col <= "1111"; -- Soltar
        wait for 100 us;
        
        -- Pulsar tecla 'F' / Igual (Almohadilla '#' -> Fila 3: "0111", Columna 2: "1011")
        sim_key_row <= "0111"; sim_key_col <= "1011";
        wait for 100 us;
        sim_key_row <= "1111"; sim_key_col <= "1111"; -- Soltar
        
        -- Esperar lo suficiente para que la CPU divida el resultado entre 10 
        -- y envíe el dígito '5' al controlador I2C de la pantalla.
        wait for 1000 us;
        
        -- Fin de simulación
        assert false report "Simulación Terminada Exitosamente" severity failure;
        wait;
    end process;
end behavior;