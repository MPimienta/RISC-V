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
    
    signal keypad_col  : std_logic_vector(3 downto 0);
    signal keypad_row  : std_logic_vector(3 downto 0);

    signal led         : std_logic_vector(15 downto 0);
    signal seg         : std_logic_vector(6 downto 0);
    signal dp          : std_logic;
    signal an          : std_logic_vector(3 downto 0);
    signal oled_cs     : std_logic;
    signal oled_sdin   : std_logic;
    signal oled_sclk   : std_logic;
    signal oled_dc     : std_logic;
    signal oled_res    : std_logic;
    signal oled_vbat   : std_logic;
    signal oled_vdd    : std_logic;

    constant clk_period : time := 100 ns; -- 10 MHz

    -- SEÑALES PARA EMULAR EL DEDO DEL USUARIO
    signal sim_row : integer := -1;
    signal sim_col : integer := -1;

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
    -- EMULADOR FÍSICO DEL TECLADO MATRICIAL (Circuito Concurrente)
    -- Esto actúa como los contactos metálicos de los botones
    -- ==========================================
    process(keypad_row, sim_row, sim_col)
    begin
        keypad_col <= "1111"; -- Por defecto, los Pull-ups tiran a '1'
        if sim_row /= -1 and sim_col /= -1 then
            -- Si hay un dedo puesto, la columna copia EXACTAMENTE 
            -- lo que haga la fila en tiempo real
            keypad_col(sim_col) <= keypad_row(sim_row);
        end if;
    end process;

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
    -- ==========================================
    -- PROCESO DE ESTÍMULOS PRINCIPAL
    -- ==========================================
    stim_proc: process
    begin		
        btn_reset <= '1';
        sim_row <= -1; sim_col <= -1; 
        wait for clk_period * 10; 
        
        btn_reset <= '0';
        wait for 3 us; 
        
        -- ====================================================
        -- 1. INTENTO FALLIDO: Metemos '8', '8', '8', '8'
        -- Al cuarto '8', la CPU lo evaluará, fallará y reseteará la RAM.
        -- ====================================================
        --for i in 0 to 3 loop
        --    sim_row <= 2; sim_col <= 1; -- Tecla '8'
        --    wait for 100 us; 
        --    sim_row <= -1; sim_col <= -1; -- Soltar
        --    wait for 50 us; 
        --end loop;
        
        -- Damos un poquito de margen para que la CPU haga la comprobación y el reset
        wait for 20 us;

        -- ====================================================
        -- 2. INTENTO CORRECTO: '1' -> '2' -> '3' -> '4'
        -- ====================================================
        -- Tecla '1'
        sim_row <= 0; sim_col <= 0; wait for 1 ms; 
        sim_row <= -1; sim_col <= -1; wait for 1 ms;

        -- Tecla '2'
        sim_row <= 0; sim_col <= 1; wait for 1 ms; 
        sim_row <= -1; sim_col <= -1; wait for 1 ms;

        -- Tecla '3'
        sim_row <= 0; sim_col <= 2; wait for 1 ms; 
        sim_row <= -1; sim_col <= -1; wait for 1 ms;

        -- Tecla '4'
        sim_row <= 1; sim_col <= 0; wait for 1 ms; 
        sim_row <= -1; sim_col <= -1; wait for 1 ms;
        
        -- ====================================================
        -- ¡AHORA SÍ! Aquí la señal `led` pasará a x"00FF"
        -- ====================================================
        wait;
    end process;



end Behavioral;