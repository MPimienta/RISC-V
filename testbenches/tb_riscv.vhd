library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_riscv_oled is
end tb_riscv_oled;

architecture behavior of tb_riscv_oled is

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
            
            -- NUEVOS PINES OLED SPI
            oled_cs    : out std_logic;
            oled_sdin  : out std_logic;
            oled_sclk  : out std_logic;
            oled_dc    : out std_logic;
            oled_res   : out std_logic;
            oled_vbat  : out std_logic;
            oled_vdd   : out std_logic
        );
    end component;

    -- Señales de entrada
    signal btn_clk    : std_logic := '0';
    signal clk        : std_logic := '0';
    signal btn_reset  : std_logic := '0';
    signal swt        : std_logic_vector (15 downto 0) := (others => '0');
    signal keypad_col : std_logic_vector(3 downto 0) := "1111";

    -- Señales de salida
    signal led        : std_logic_vector (15 downto 0);
    signal seg        : std_logic_vector (6 downto 0);
    signal dp         : std_logic;
    signal an         : std_logic_vector (3 downto 0);
    signal keypad_row : std_logic_vector(3 downto 0);
    
    -- Señales de la OLED
    signal oled_cs    : std_logic;
    signal oled_sdin  : std_logic;
    signal oled_sclk  : std_logic;
    signal oled_dc    : std_logic;
    signal oled_res   : std_logic;
    signal oled_vbat  : std_logic;
    signal oled_vdd   : std_logic;

    constant clk_period : time := 10 ns; -- Reloj de alta frecuencia (100 MHz)

begin

    -- Instanciación del Top Level (RISC-V)
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
        oled_cs    => oled_cs,
        oled_sdin  => oled_sdin,
        oled_sclk  => oled_sclk,
        oled_dc    => oled_dc,
        oled_res   => oled_res,
        oled_vbat  => oled_vbat,
        oled_vdd   => oled_vdd
    );

    -- Generador de Reloj del Sistema (100 MHz)
    -- Este reloj alimenta la lógica SPI y los debouncers
    clk_process :process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;
    
    -- Generador de Reloj de la CPU (Pipeline)
    -- En hardware real, esto vendría de un botón, pero en simulación
    -- lo automatizamos para que la CPU corra instrucciones sin parar.
    btn_clk_process :process
    begin
        btn_clk <= '0'; wait for 50 ns;
        btn_clk <= '1'; wait for 50 ns;
    end process;

    stim_proc: process
    begin
        -- 1. Reset inicial
        btn_reset <= '1';
        wait for 200 ns;
        btn_reset <= '0';
        
        -- =========================================================================
        -- ¡TRUCO DE SIMULACIÓN!
        -- El programa en ROM tiene un bucle de retardo anidado muy largo (instrucciones 3 a 8).
        -- Para que no tengas que esperar horas de simulación a que pase ese bucle:
        -- VE A TU ARCHIVO 'rom_instructions.vhd' y cambia temporalmente:
        -- 3  => x"42FF", -- LI r1, 255   ---> POR --->  3  => x"4202", -- LI r1, 2
        -- 4  => x"44FF", -- LI r2, 255   ---> POR --->  4  => x"4402", -- LI r2, 2
        -- Así el bucle pasará casi al instante y verás las transmisiones SPI rápido.
        -- =========================================================================
        
        -- Dejamos que la CPU ejecute el código de la ROM durante un buen rato.
        -- Ajusta este tiempo si ves que la simulación se detiene antes de enviar "Hola".
        wait for 1000 us; 
        
        -- Fin de simulación
        assert false report "Simulación Terminada Exitosamente" severity failure;
        wait;
    end process;
end behavior;