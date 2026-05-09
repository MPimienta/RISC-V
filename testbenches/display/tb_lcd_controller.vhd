library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_lcd_controller is
end tb_lcd_controller;

architecture Behavioral of tb_lcd_controller is

    component lcd_controller
        Generic ( clk_freq : integer );
        Port (
            clk      : in  std_logic;
            reset    : in  std_logic;
            char_in  : in  std_logic_vector(7 downto 0);
            char_we  : in  std_logic;
            cmd_in   : in  std_logic_vector(7 downto 0);
            cmd_we   : in  std_logic;
            busy     : out std_logic;
            i2c_ena  : out std_logic;
            i2c_data : out std_logic_vector(7 downto 0);
            i2c_busy : in  std_logic
        );
    end component;
    
    component i2c_master
        Generic ( input_clk : integer; bus_clk : integer );
        Port (
            clk       : in    std_logic;
            reset     : in    std_logic;
            ena       : in    std_logic;
            addr      : in    std_logic_vector(6 downto 0);
            rw        : in    std_logic;
            data_wr   : in    std_logic_vector(7 downto 0);
            busy      : out   std_logic;
            ack_error : out   std_logic;
            sda       : inout std_logic;
            scl       : inout std_logic
        );
    end component;

    -- Señales globales
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';
    
    -- Señales de interfaz Driver -> Master
    signal conn_i2c_ena  : std_logic;
    signal conn_i2c_data : std_logic_vector(7 downto 0);
    signal conn_i2c_busy : std_logic;
    
    -- Señales de control del Testbench -> Driver
    signal tb_char_in : std_logic_vector(7 downto 0) := x"00";
    signal tb_char_we : std_logic := '0';
    signal tb_cmd_in  : std_logic_vector(7 downto 0) := x"00";
    signal tb_cmd_we  : std_logic := '0';
    signal tb_lcd_busy: std_logic;
    
    -- Señales físicas I2C
    signal sda : std_logic;
    signal scl : std_logic;

    constant clk_period : time := 10 ns;

begin

    -- Para la simulación, reducimos drásticamente las esperas usando clk_freq bajo
    -- De lo contrario, la simulación tardaría horas en pasar los 50ms iniciales
    inst_driver: lcd_controller
    generic map ( clk_freq => 10_000 ) -- Frecuencia falsa para acelerar simulación
    port map (
        clk => clk, reset => reset,
        char_in => tb_char_in, char_we => tb_char_we,
        cmd_in => tb_cmd_in, cmd_we => tb_cmd_we, busy => tb_lcd_busy,
        i2c_ena => conn_i2c_ena, i2c_data => conn_i2c_data, i2c_busy => conn_i2c_busy
    );

    inst_master: i2c_master
    generic map ( input_clk => 100_000_000, bus_clk => 400_000 )
    port map (
        clk => clk, reset => reset,
        ena => conn_i2c_ena, addr => "0100111", rw => '0',
        data_wr => conn_i2c_data, busy => conn_i2c_busy, ack_error => open,
        sda => sda, scl => scl
    );

    -- Generador de Reloj
    clk_process : process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    -- Estímulos
    stim_proc: process
    begin
        reset <= '1';
        wait for 1 us;
        reset <= '0';
        
        -- El driver se pasará a inicializar la pantalla.
        -- Esperamos a que termine (busy bajará a '0')
        wait until tb_lcd_busy = '0';
        wait for 10 us;
        
        -- Mandamos el carácter 'H' (ASCII 0x48)
        tb_char_in <= x"48";
        tb_char_we <= '1';
        wait for clk_period;
        tb_char_we <= '0';
        
        wait until tb_lcd_busy = '0';
        wait for 10 us;
        
        -- Mandamos comando "Salto a línea 2" (Comando 0xC0)
        tb_cmd_in <= x"C0";
        tb_cmd_we <= '1';
        wait for clk_period;
        tb_cmd_we <= '0';
        
        wait;
    end process;

end Behavioral;