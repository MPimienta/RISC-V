library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_lcd_controller is
end tb_lcd_controller;

architecture Behavioral of tb_lcd_controller is

    -- Componente a testear
    component lcd_controller
        Port (
            clk      : in  std_logic;
            reset    : in  std_logic;
            lcd_we   : in  std_logic;
            data_in  : in  std_logic_vector(15 downto 0);
            i2c_ena  : out std_logic;
            i2c_data : out std_logic_vector(7 downto 0);
            i2c_busy : in  std_logic;
            i2c_addr : out std_logic_vector(6 downto 0)
        );
    end component;

    -- Señales de estímulo
    signal clk      : std_logic := '0';
    signal reset    : std_logic := '1';
    signal lcd_we   : std_logic := '0';
    signal data_in  : std_logic_vector(15 downto 0) := x"ABCD"; -- Dato de prueba

    -- Señales de interconexión
    signal i2c_ena  : std_logic;
    signal i2c_data : std_logic_vector(7 downto 0);
    signal i2c_busy : std_logic := '0';
    signal i2c_addr : std_logic_vector(6 downto 0);

    -- Reloj de 100MHz (10ns de periodo)
    constant clk_period : time := 10 ns;

begin

    -- Instancia del controlador
    uut: lcd_controller
        port map (
            clk      => clk,
            reset    => reset,
            lcd_we   => lcd_we,
            data_in  => data_in,
            i2c_ena  => i2c_ena,
            i2c_data => i2c_data,
            i2c_busy => i2c_busy,
            i2c_addr => i2c_addr
        );

    -- Generador de reloj
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- LÓGICA DE SIMULACIÓN DEL MASTER I2C
    -- Este proceso "engaña" al controlador haciéndole creer que el Master
    -- está procesando los datos cada vez que i2c_ena se pone a '1'.
    i2c_sim : process(clk)
        variable count : integer := 0;
    begin
        if rising_edge(clk) then
            if i2c_ena = '1' and i2c_busy = '0' then
                i2c_busy <= '1';
                count := 0;
            elsif i2c_busy = '1' then
                if count < 50 then -- Simulamos que el envío I2C tarda 50 ciclos
                    count := count + 1;
                else
                    i2c_busy <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Proceso de estímulos principales
    stim_proc: process
    begin		
        reset <= '1';
        lcd_we <= '0';
        wait for 100 ns;
        reset <= '0';
        
        -- CAMBIO AQUÍ: En lugar de un tiempo fijo, esperamos a que llegue a IDLE
        -- Mirando tu gráfica, esto ocurre después de las ráfagas de inicialización.
        wait for 20 us; -- Esperamos un poco más de los 18us que se ven en tu imagen
        
        report "Enviando dato xABCD...";
        data_in <= x"ABCD";
        lcd_we  <= '1';   -- Ahora sí, el controlador está libre para escucharte
        wait for clk_period;
        lcd_we  <= '0';

        wait for 1 ms; -- Tiempo para ver el envío de los 4 dígitos
        assert false report "Fin de simulación" severity failure;
    end process;

end Behavioral;