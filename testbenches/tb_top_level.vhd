library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_top_level is
-- Sin puertos, es un testbench
end tb_top_level;

architecture sim of tb_top_level is

    -- Definición del reloj principal (100 MHz)
    constant CLK_PERIOD : time := 10 ns;

    -- Señales de entrada
    signal clk         : std_logic := '0';
    signal btn_clk     : std_logic := '0';
    signal btn_reset   : std_logic := '1';
    signal btn_add     : std_logic := '0';
    signal btn_sub     : std_logic := '0';
    signal swt         : std_logic_vector(15 downto 0) := (others => '0');
    signal keypad_col  : std_logic_vector(3 downto 0)  := (others => '0');

    -- Señales de salida
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

begin

    -- Instanciación de tu módulo principal
    uut: entity work.top_level
    port map (
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

    -- Generador del reloj principal
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Proceso de estímulos (Simulación de la interacción humana)
    stimulus_process: process
    begin
        -- Estado inicial: Mantenemos el reset activo un momento
        btn_reset <= '1';
        btn_clk   <= '0';
        btn_add   <= '0';
        btn_sub   <= '0';
        swt       <= x"0000";
        keypad_col <= "0000";
        wait for 50 ns;
        
        -- Liberamos el reset para que el procesador arranque
        btn_reset <= '0';
        wait for 200 ns;

        -- Simulamos la configuración de unos valores en los interruptores (Switches)
        swt <= x"0015"; -- Equivale a 21 en decimal
        wait for 100 ns;

        -- Simulamos que el usuario presiona el botón "Add" durante unos ciclos
        btn_add <= '1';
        wait for 50 ns;
        btn_add <= '0'; -- Soltamos el botón
        
        -- Damos tiempo para que el procesador ejecute sus instrucciones de lectura,
        -- haga el cálculo en la ALU y envíe el resultado al display y los LEDs.
        wait for 1500 ns; 

        -- Simulamos el uso de otro periférico (Switches distintos y botón Sub)
        swt <= x"00A0"; -- Equivale a 160 en decimal
        wait for 100 ns;
        
        btn_sub <= '1';
        wait for 50 ns;
        btn_sub <= '0';
        
        -- Damos un tiempo de espera largo para observar la transmisión del OLED
        -- y el multiplexado rápido de los ánodos (señal 'an') del display 7 segmentos.
        wait for 5000 ns;

        -- Fin de la simulación
        wait;
    end process;

end sim;