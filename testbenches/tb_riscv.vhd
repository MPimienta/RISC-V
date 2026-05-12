library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity riscv_tb is
end riscv_tb;

architecture behavior of riscv_tb is

    component riscv
        Port ( 
            btn_clk     : in std_logic;
            clk         : in std_logic;
            btn_reset   : in std_logic;
            swt         : in std_logic_vector (15 downto 0);
            led         : out std_logic_vector (15 downto 0);
            seg         : out std_logic_vector (6 downto 0);
            dp          : out std_logic;
            an          : out std_logic_vector (3 downto 0);
            keypad_col  : in std_logic_vector(3 downto 0);
            keypad_row  : out std_logic_vector(3 downto 0);
            -- Nuevos puertos para la pantalla LCD
            sda         : inout std_logic;
            scl         : inout std_logic
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

    -- Señales I2C inicializadas en 'H' (Weak High) para simular los Pull-Ups del I2C
    signal sda : std_logic := 'H';
    signal scl : std_logic := 'H';

    constant clk_period : time := 10 ns;

begin

    uut: riscv Port map (
        btn_clk => btn_clk, 
        clk => clk, 
        btn_reset => btn_reset,
        swt => swt, 
        led => led, 
        seg => seg, 
        dp => dp, 
        an => an,
        keypad_col => keypad_col, 
        keypad_row => keypad_row,
        sda => sda,
        scl => scl
    );

    -- Reloj principal del sistema (100 MHz)
    clk_process :process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    stim_proc: process
    begin
        -- Inicialización de Switches
        swt(2) <= '1';
        swt(4) <= '1';
        swt(6) <= '1';
        
        -- Reset inicial
        btn_reset <= '1';
        wait for 100 ns;
        btn_reset <= '0';
        wait for 100 ns;
        
        -- Esperamos un poco (si has bajado el PRESCALER_MAX, esto será suficiente)
        wait for 500 ns;
        
        -- Sincronizamos con el barrido del teclado para pulsar en el momento justo
        wait until keypad_row = "1101";
        
        -- Simulamos la pulsación del botón (Cierra circuito Fila 1 -> Col 1)
        keypad_col <= "1101";

        -- Avanzamos el reloj de la CPU para que procese la tecla
        for i in 1 to 20 loop
            btn_clk <= '1';
            wait for 200 ns; 
            btn_clk <= '0';
            wait for 200 ns;
        end loop;
        
        -- Soltamos la tecla
        keypad_col <= "1111";
        wait for 500 ns;
        
        -- Seguimos ejecutando la CPU
        for i in 1 to 80 loop
            btn_clk <= '1';
            wait for 200 ns; 
            btn_clk <= '0';
            wait for 200 ns;
        end loop;

        wait;
    end process;
end behavior;