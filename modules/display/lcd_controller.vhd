library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lcd_controller is
    Generic (
        clk_freq : integer := 100_000_000 -- 100 MHz
    );
    Port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        
        -- Interfaz de Control (hacia el Display Manager)
        char_in     : in  std_logic_vector(7 downto 0); -- Carácter ASCII a enviar
        char_we     : in  std_logic;                    -- Write Enable para carácter
        cmd_in      : in  std_logic_vector(7 downto 0); -- Comando crudo (ej: clear, cursor)
        cmd_we      : in  std_logic;                    -- Write Enable para comando
        busy        : out std_logic;                    -- '1' si no puede aceptar datos
        
        -- Interfaz I2C (hacia i2c_master)
        i2c_ena     : out std_logic;
        i2c_data    : out std_logic_vector(7 downto 0);
        i2c_busy    : in  std_logic
    );
end lcd_controller;

architecture Behavioral of lcd_controller is
    -- Tiempos de espera (calculados para 100MHz)
    constant MS_50   : integer := 5_000_000;
    constant MS_5    : integer := 500_000;
    constant US_200  : integer := 20_000;
    constant US_50   : integer := 5_000;

    type state_type is (
        POWER_UP, INIT_WAIT, INIT_SEND, 
        IDLE, 
        NIBBLE_HIGH_EN1, NIBBLE_HIGH_EN0, 
        NIBBLE_LOW_EN1, NIBBLE_LOW_EN0,
        WAIT_I2C, WAIT_CMD
    );
    signal state : state_type := POWER_UP;
    signal return_state : state_type := IDLE; -- Para saber a dónde volver tras enviar a I2C
    
    signal delay_timer : integer := 0;
    signal delay_target: integer := 0;
    
    -- Secuencia de inicialización (Comandos + Tiempos de espera asociados)
    -- El estándar dice: x33 (wait 5ms), x32 (wait 200us), x28 (4-bit, 2 lines), x0C (Disp on, cursor off), x01 (Clear), x06 (Entry mode)
    type init_cmd_array is array (0 to 6) of std_logic_vector(7 downto 0);
    type init_wait_array is array (0 to 6) of integer;
    
    constant INIT_CMDS  : init_cmd_array  := (x"33", x"32", x"28", x"0C", x"01", x"06", x"00");
    constant INIT_WAITS : init_wait_array := (MS_5,  US_200, US_50, US_50, MS_5,  US_50, 0);
    
    signal init_idx : integer range 0 to 7 := 0;
    
    signal s_i2c_ena  : std_logic := '0';
    signal s_i2c_data : std_logic_vector(7 downto 0) := x"00";
    
    -- Registro del byte actual a enviar al I2C (Nibble Alto y Bajo)
    signal current_byte : std_logic_vector(7 downto 0);
    signal rs_bit       : std_logic; -- '1' para Datos (caracteres), '0' para Comandos
    
    -- Mapeo PCF8574: P7..P4=D7..D4 | P3=Backlight | P2=Enable | P1=RW | P0=RS
    constant BL : std_logic := '1'; -- Backlight siempre ON
    constant RW : std_logic := '0'; -- Siempre escribimos

begin

    i2c_ena  <= s_i2c_ena;
    i2c_data <= s_i2c_data;
    
    -- Está busy si no está en IDLE o si el I2C está ocupado
    busy <= '0' when state = IDLE else '1';

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= POWER_UP;
                delay_timer <= 0;
                init_idx <= 0;
                s_i2c_ena <= '0';
            else
                case state is
                
                    -- 1. Espera inicial de 50ms al encender
                    when POWER_UP =>
                        if delay_timer < MS_50 then
                            delay_timer <= delay_timer + 1;
                        else
                            delay_timer <= 0;
                            state <= INIT_SEND;
                        end if;

                    -- 2. Enviar secuencia de inicialización
                    when INIT_SEND =>
                        if init_idx < 6 then
                            current_byte <= INIT_CMDS(init_idx);
                            rs_bit <= '0'; -- Inicialización son comandos
                            delay_target <= INIT_WAITS(init_idx);
                            state <= NIBBLE_HIGH_EN1;
                            return_state <= INIT_WAIT;
                        else
                            state <= IDLE;
                        end if;
                        
                    -- 3. Esperar el tiempo requerido por el comando de inicialización
                    when INIT_WAIT =>
                        if delay_timer < delay_target then
                            delay_timer <= delay_timer + 1;
                        else
                            delay_timer <= 0;
                            init_idx <= init_idx + 1;
                            state <= INIT_SEND;
                        end if;

                    -- 4. Estado de Reposo: Esperar peticiones
                    when IDLE =>
                        if char_we = '1' then
                            current_byte <= char_in;
                            rs_bit <= '1'; -- Es un carácter (Data)
                            state <= NIBBLE_HIGH_EN1;
                            delay_target <= US_50; -- Tiempo normal de escritura
                            return_state <= WAIT_CMD;
                        elsif cmd_we = '1' then
                            current_byte <= cmd_in;
                            rs_bit <= '0'; -- Es un comando
                            state <= NIBBLE_HIGH_EN1;
                            -- Si es clear (0x01) o return home (0x02), necesita más tiempo
                            if cmd_in = x"01" or cmd_in = x"02" then
                                delay_target <= MS_5; 
                            else
                                delay_target <= US_50;
                            end if;
                            return_state <= WAIT_CMD;
                        end if;

                    -- 5. Secuencia de Envío de 4 bits (Nibble Alto)
                    when NIBBLE_HIGH_EN1 =>
                        if i2c_busy = '0' and s_i2c_ena = '0' then
                            -- D7 D6 D5 D4 | BL EN RW RS
                            s_i2c_data <= current_byte(7 downto 4) & BL & '1' & RW & rs_bit;
                            s_i2c_ena <= '1';
                            state <= WAIT_I2C;
                        end if;
                        
                    when NIBBLE_HIGH_EN0 =>
                        if i2c_busy = '0' and s_i2c_ena = '0' then
                            s_i2c_data <= current_byte(7 downto 4) & BL & '0' & RW & rs_bit;
                            s_i2c_ena <= '1';
                            state <= WAIT_I2C;
                        end if;

                    -- 6. Secuencia de Envío de 4 bits (Nibble Bajo)
                    when NIBBLE_LOW_EN1 =>
                        if i2c_busy = '0' and s_i2c_ena = '0' then
                            s_i2c_data <= current_byte(3 downto 0) & BL & '1' & RW & rs_bit;
                            s_i2c_ena <= '1';
                            state <= WAIT_I2C;
                        end if;

                    when NIBBLE_LOW_EN0 =>
                        if i2c_busy = '0' and s_i2c_ena = '0' then
                            s_i2c_data <= current_byte(3 downto 0) & BL & '0' & RW & rs_bit;
                            s_i2c_ena <= '1';
                            state <= WAIT_I2C;
                        end if;

                    -- Sincronización I2C y avance de secuencia de Nibbles
                    when WAIT_I2C =>
                        if i2c_busy = '1' then
                            s_i2c_ena <= '0'; -- Bajamos la petición una vez que el máster la ha cogido
                        elsif i2c_busy = '0' and s_i2c_ena = '0' then
                            -- Determinar siguiente paso en la secuencia de nibbles
                            if s_i2c_data(2) = '1' then -- Si acabamos de mandar un EN=1
                                if s_i2c_data(7 downto 4) = current_byte(7 downto 4) then
                                    state <= NIBBLE_HIGH_EN0;
                                else
                                    state <= NIBBLE_LOW_EN0;
                                end if;
                            else -- Si acabamos de mandar un EN=0
                                if s_i2c_data(7 downto 4) = current_byte(7 downto 4) then
                                    state <= NIBBLE_LOW_EN1;
                                else
                                    state <= return_state; -- Fin de la transmisión del byte completo
                                end if;
                            end if;
                        end if;
                        
                    -- Espera tras un comando o carácter normal
                    when WAIT_CMD =>
                        if delay_timer < delay_target then
                            delay_timer <= delay_timer + 1;
                        else
                            delay_timer <= 0;
                            state <= IDLE;
                        end if;
                        
                end case;
            end if;
        end if;
    end process;
end Behavioral;