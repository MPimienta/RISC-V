library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lcd_controller is
    Port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        lcd_we   : in  std_logic;                    -- Señal de escritura del Decoder
        data_in  : in  std_logic_vector(15 downto 0);-- Dato de la CPU (16 bits)
        -- Interfaz con el Master I2C
        i2c_ena  : out std_logic;
        i2c_data : out std_logic_vector(7 downto 0);
        i2c_busy : in  std_logic;
        i2c_addr : out std_logic_vector(6 downto 0)
    );
end lcd_controller;

architecture Behavioral of lcd_controller is
    -- Estados de la FSM
    type state_type is (IDLE, POWER_UP, SEND_INIT, PREPARE_DATA, SEND_CHAR, WAIT_I2C);
    signal state : state_type := POWER_UP;
    
    -- Señales internas para evitar errores de lectura en puertos 'out'
    signal s_i2c_ena  : std_logic := '0';
    signal s_i2c_data : std_logic_vector(7 downto 0) := (others => '0');

    -- Comandos de inicialización (Modo 4 bits para PCF8574)
    type init_array is array (0 to 5) of std_logic_vector(7 downto 0);
    constant INIT_CMDS : init_array := (x"33", x"32", x"28", x"0C", x"06", x"01");
    
    signal init_idx   : integer range 0 to 6 := 0;
    signal char_cnt   : integer range 0 to 3 := 0;   -- Para recorrer los 4 dígitos hex
    signal nibble_sel : integer range 0 to 3 := 0;   -- Los 4 pasos del protocolo I2C-LCD
    signal current_ascii : std_logic_vector(7 downto 0);
    signal is_data    : std_logic := '0';            -- '1' para caracteres, '0' para comandos
    signal timer      : integer := 0;

    -- Función para convertir un nibble (4 bits) a su carácter ASCII Hexadecimal
    function to_ascii(hex : std_logic_vector(3 downto 0)) return std_logic_vector is
    begin
        case hex is
            when x"0" => return x"30"; when x"1" => return x"31";
            when x"2" => return x"32"; when x"3" => return x"33";
            when x"4" => return x"34"; when x"5" => return x"35";
            when x"6" => return x"36"; when x"7" => return x"37";
            when x"8" => return x"38"; when x"9" => return x"39";
            when x"A" => return x"41"; when x"B" => return x"42";
            when x"C" => return x"43"; when x"D" => return x"44";
            when x"E" => return x"45"; when x"F" => return x"46";
            when others => return x"20"; -- Espacio en blanco
        end case;
    end function;

begin
    -- Asignaciones constantes y puentes a puertos de salida
    i2c_addr <= "0100111"; -- Dirección I2C 0x27
    i2c_ena  <= s_i2c_ena;
    i2c_data <= s_i2c_data;

    process(clk)
        variable digit : std_logic_vector(3 downto 0);
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= POWER_UP;
                timer <= 0;
                s_i2c_ena <= '0';
                init_idx <= 0;
                nibble_sel <= 0;
            else
                case state is
                    
                    -- 1. Espera inicial para estabilizar voltaje (50ms)
                    when POWER_UP =>
                        if timer < 100 then  -- IMPORTANTE CAMBIAR A 5000000 PARA DESCARGAR EN PLACA POR LA DIFERENCIA DE HZ ENTRE SIMULACION Y PLACA
                            timer <= timer + 1;
                        else 
                            state <= SEND_INIT; 
                            init_idx <= 0; 
                        end if;

                    -- 2. Envío de comandos de configuración
                    when SEND_INIT =>
                        if init_idx < 6 then
                            current_ascii <= INIT_CMDS(init_idx);
                            is_data <= '0'; 
                            state <= SEND_CHAR;
                        else 
                            state <= IDLE; 
                        end if;

                    -- 3. Espera a que el Decoder active lcd_we
                    when IDLE =>
                        if lcd_we = '1' then
                            char_cnt <= 0;
                            state <= PREPARE_DATA;
                        end if;

                    -- 4. Seleccionar cuál de los 4 dígitos hex enviar
                    when PREPARE_DATA =>
                        case char_cnt is
                            when 0 => digit := data_in(15 downto 12);
                            when 1 => digit := data_in(11 downto 8);
                            when 2 => digit := data_in(7 downto 4);
                            when 3 => digit := data_in(3 downto 0);
                        end case;
                        current_ascii <= to_ascii(digit);
                        is_data <= '1';
                        state <= SEND_CHAR;

                    -- 5. Protocolo de 4 bits sobre I2C (Envío de Nibbles con Enable)
                    when SEND_CHAR =>
                        if i2c_busy = '0' and s_i2c_ena = '0' then
                            -- El bit 3 es Backlight (1=ON), Bit 2 es Enable (EN), Bit 0 es RS
                            case nibble_sel is
                                -- Nibble Alto
                                when 0 => s_i2c_data <= current_ascii(7 downto 4) & '1' & '1' & '0' & is_data; -- EN=1
                                when 1 => s_i2c_data <= current_ascii(7 downto 4) & '1' & '0' & '0' & is_data; -- EN=0
                                -- Nibble Bajo
                                when 2 => s_i2c_data <= current_ascii(3 downto 0) & '1' & '1' & '0' & is_data; -- EN=1
                                when 3 => s_i2c_data <= current_ascii(3 downto 0) & '1' & '0' & '0' & is_data; -- EN=0
                            end case;
                            s_i2c_ena <= '1'; 
                            state <= WAIT_I2C;
                        end if;

                    -- 6. Sincronización con el Master I2C
                    when WAIT_I2C =>
                        if i2c_busy = '1' then 
                            s_i2c_ena <= '0';
                        elsif i2c_busy = '0' and s_i2c_ena = '0' then
                            if nibble_sel = 3 then
                                nibble_sel <= 0;
                                -- Decidir si seguir inicializando, enviar siguiente carácter o volver a IDLE
                                if init_idx /= 6 then 
                                    init_idx <= init_idx + 1;
                                    state <= SEND_INIT;
                                elsif char_cnt < 3 then 
                                    char_cnt <= char_cnt + 1;
                                    state <= PREPARE_DATA;
                                else 
                                    state <= IDLE; 
                                end if;
                            else 
                                nibble_sel <= nibble_sel + 1;
                                state <= SEND_CHAR; 
                            end if;
                        end if;

                    when others => state <= IDLE;
                end case;
            end if;
        end if;
    end process;
end Behavioral;