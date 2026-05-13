library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_keypad_test is
end tb_keypad_test;

architecture behavior of tb_keypad_test is

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
            
            -- PINES OLED (Los dejamos conectados para que compile, aunque no los miremos hoy)
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
    
    -- Señales OLED (Dummies)
    signal oled_cs, oled_sdin, oled_sclk, oled_dc, oled_res, oled_vbat, oled_vdd : std_logic;

    constant clk_period : time := 10 ns; -- Reloj de 100 MHz

    -- Señales para "engañar" al controlador matricial
    signal sim_key_row : std_logic_vector(3 downto 0) := "1111";
    signal sim_key_col : std_logic_vector(3 downto 0) := "1111";

begin

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

    -- Generador de Reloj del Sistema
    clk_process :process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;
    
    -- LÓGICA DEL TECLADO MATRICIAL (Espejo de la realidad)
    -- Si la fila que está escaneando la FPGA coincide con la tecla que queremos pulsar, 
    -- bajamos la columna correspondiente a '0'. Si no, la dejamos en '1' (alta impedancia virtual).
    keypad_col <= sim_key_col when (keypad_row = sim_key_row) else "1111";

    stim_proc: process
    begin
        -- 1. Reset
        btn_reset <= '1';
        wait for 200 ns;
        btn_reset <= '0';
        
        -- Esperamos un poco para que el controlador del teclado arranque
        wait for 5 us; 

        -- =========================================================================
        -- PRUEBA 1: Pulsar la tecla '3' (Hex: 0x3)
        -- =========================================================================
        -- Fila 0 ("1110"), Columna 2 ("1011")
        sim_key_row <= "1110"; sim_key_col <= "1011";
        wait for 15 us; -- Mantener pulsado (Debe dar tiempo al prescaler a hacer varios escaneos)
        
        -- Soltar la tecla
        sim_key_row <= "1111"; sim_key_col <= "1111"; 
        wait for 10 us; 
        
        -- =========================================================================
        -- PRUEBA 2: Pulsar la tecla 'A' (Hex: 0xA)
        -- =========================================================================
        -- Fila 0 ("1110"), Columna 3 ("0111")
        sim_key_row <= "1110"; sim_key_col <= "0111";
        wait for 15 us; 
        
        -- Soltar la tecla
        sim_key_row <= "1111"; sim_key_col <= "1111"; 
        wait for 10 us;

        -- =========================================================================
        -- PRUEBA 3: Pulsar la tecla 'F' / Almohadilla (Hex: 0xF)
        -- =========================================================================
        -- Fila 3 ("0111"), Columna 2 ("1011")
        sim_key_row <= "0111"; sim_key_col <= "1011";
        wait for 15 us;
        
        sim_key_row <= "1111"; sim_key_col <= "1111"; 
        wait for 20 us;

        assert false report "Test de Teclado Finalizado" severity failure;
        wait;
    end process;
end behavior;