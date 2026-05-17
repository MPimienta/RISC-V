library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_top_level is
-- Un testbench no tiene puertos
end tb_top_level;

architecture Behavioral of tb_top_level is

    -- ==========================================
    -- DECLARACIÓN DEL COMPONENTE (Unit Under Test)
    -- ==========================================
    component top_level is
        Port ( 
            clk         : in std_logic;
            btn_clk     : in std_logic;
            btn_reset   : in std_logic;
            btn_add     : in std_logic;
            btn_sub     : in std_logic;
            swt         : in std_logic_vector (15 downto 0);
            led         : out std_logic_vector (15 downto 0);
            seg         : out std_logic_vector (6 downto 0);
            dp          : out std_logic;
            an          : out std_logic_vector (3 downto 0);
            keypad_col  : in std_logic_vector(3 downto 0);
            keypad_row  : out std_logic_vector(3 downto 0);
            oled_cs     : out std_logic;
            oled_sdin   : out std_logic;
            oled_sclk   : out std_logic;
            oled_dc     : out std_logic;
            oled_res    : out std_logic;
            oled_vbat   : out std_logic;
            oled_vdd    : out std_logic
        );
    end component;

    -- ==========================================
    -- SEÑALES INTERNAS PARA EL TESTBENCH
    -- ==========================================
    signal clk         : std_logic := '0';
    signal btn_clk     : std_logic := '0';
    signal btn_reset   : std_logic := '0';
    signal btn_add     : std_logic := '0';
    signal btn_sub     : std_logic := '0';
    signal swt         : std_logic_vector(15 downto 0) := (others => '0');
    
    -- Inicializamos las columnas del teclado sin pulsar
    -- (Asumiendo lógica Pmod estándar con pull-downs: "0000" es reposo)
    signal keypad_col  : std_logic_vector(3 downto 0) := "0000";

    signal led         : std_logic_vector(15 downto 0);
    signal seg         : std_logic_vector(6 downto 0);
    signal dp          : std_logic;
    signal an          : std_logic_vector(3 downto 0);
    signal keypad_row  : std_logic_vector(3 downto 0);
    signal oled_cs     : std_logic;
    signal oled_sdin   : std_logic;
    signal oled_sclk   : std_logic;
    signal oled_dc     : std_logic;
    signal oled_res    : std_logic;
    signal oled_vbat   : std_logic;
    signal oled_vdd    : std_logic;

    constant clk_period : time := 100 ns; -- 10 MHz

begin

    -- ==========================================
    -- INSTANCIACIÓN DEL TOP LEVEL (UUT)
    -- ==========================================
    UUT: top_level Port map (
        clk         => clk,
        btn_clk     => btn_clk,
        btn_reset   => btn_reset,
        btn_add     => btn_add,
        btn_sub     => btn_sub,
        swt         => swt,
        led         => led,
        seg         => seg,
        dp          => dp,
        an          => an,
        keypad_col  => keypad_col,
        keypad_row  => keypad_row,
        oled_cs     => oled_cs,
        oled_sdin   => oled_sdin,
        oled_sclk   => oled_sclk,
        oled_dc     => oled_dc,
        oled_res    => oled_res,
        oled_vbat   => oled_vbat,
        oled_vdd    => oled_vdd
    );

    -- ==========================================
    -- PROCESO DE GENERACIÓN DE RELOJ
    -- ==========================================
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- ==========================================
    -- PROCESO DE ESTÍMULOS PRINCIPAL
    -- ==========================================
    stim_proc: process
    begin		
        -- 1. ESTADO INICIAL (Reset activo y teclado suelto)
        btn_reset <= '1';
        keypad_col <= "0000"; 
        wait for clk_period * 10; 
        
        -- 2. ARRANCAR SISTEMA
        btn_reset <= '0';
        
        -- Esperamos a que la CPU ejecute el SETUP inicial (las instrucciones LI)
        -- y entre de lleno en el bucle WAIT_PRESS.
        wait for 2 us;
        
        -- ====================================================
        -- 3. SIMULAR PULSACIÓN DEL TECLADO
        -- ====================================================
        -- Activamos una columna. Cuando el keypad_controller interno
        -- active la fila correspondiente, registrará un "hit".
        keypad_col <= "0010";
        
        -- IMPORTANTE: Mantenemos la tecla pulsada el tiempo suficiente para:
        -- a) Superar el contador del debouncer del keypad_controller.
        -- b) Que la CPU lea la dirección 0xFFE2 y rompa el bucle WAIT_PRESS.
        -- c) Que envíe el dato por SPI (WAIT_OLED y escritura).
        -- Si en la simulación no ves que la CPU avanza, AUMENTA este tiempo,
        -- o reduce el contador del debouncer en tu keypad_controller.vhd.
        wait for 50 us; 
        
        -- ====================================================
        -- 4. SIMULAR LIBERACIÓN DEL TECLADO
        -- ====================================================
        -- Soltamos la tecla. Esto permitirá que la CPU rompa el 
        -- segundo bucle (WAIT_RELEASE) y vuelva al inicio.
        keypad_col <= "0000";
        
        -- Observamos el sistema durante unos microsegundos más para 
        -- verificar que la CPU vuelve a hacer polling pacíficamente.
        wait for 20 us;

        -- Fin de los estímulos
        wait;
    end process;

end Behavioral;