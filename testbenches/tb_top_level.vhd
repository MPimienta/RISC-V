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
    -- Entradas (inicializadas a 0)
    signal clk         : std_logic := '0';
    signal btn_clk     : std_logic := '0';
    signal btn_reset   : std_logic := '0';
    signal btn_add     : std_logic := '0';
    signal btn_sub     : std_logic := '0';
    signal swt         : std_logic_vector(15 downto 0) := (others => '0');
    signal keypad_col  : std_logic_vector(3 downto 0) := "0000";

    -- Salidas
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

    -- Definición del periodo del reloj (10 MHz = 100 ns)
    constant clk_period : time := 100 ns;

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
        -- 1. Estado inicial: Mantener el sistema en reset
        btn_reset <= '1';
        swt <= x"0000";
        wait for clk_period * 5; 
        
        -- 2. Liberar el reset (La CPU empieza a hacer fetch en la ROM)
        btn_reset <= '0';
        
        -- Dejar que la CPU ejecute instrucciones un tiempo...
        wait for clk_period * 50;
        
        -- 3. (Opcional) Simular interacción del usuario
        -- Por ejemplo, encender el switch 0 para que la CPU lo lea por MMIO
        swt <= x"0001";
        wait for clk_period * 50;
        
        -- Encender un botón
        btn_add <= '1';
        wait for clk_period * 10;
        btn_add <= '0';

        -- Dejar el sistema corriendo indefinidamente
        -- (En Vivado deberás pausar la simulación manualmente o definir un tiempo de fin)
        wait;
    end process;

end Behavioral;