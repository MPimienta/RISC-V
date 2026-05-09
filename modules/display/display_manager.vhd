library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity display_manager is
    Port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        
        -- Datos provenientes de la CPU (Ejemplo RISC-V básico)
        cpu_state   : in  std_logic_vector(2 downto 0);  -- 0:FET, 1:DEC, 2:EXE, 3:MEM, 4:WB
        cpu_opcode  : in  std_logic_vector(6 downto 0);
        cpu_rd      : in  std_logic_vector(4 downto 0);
        cpu_data    : in  std_logic_vector(15 downto 0); -- Dato o ALU result a mostrar
        
        -- Interfaz hacia el LCD Driver
        lcd_busy    : in  std_logic;
        char_out    : out std_logic_vector(7 downto 0);
        char_we     : out std_logic;
        cmd_out     : out std_logic_vector(7 downto 0);
        cmd_we      : out std_logic
    );
end display_manager;

architecture Behavioral of display_manager is

    -- Memoria de pantalla: 32 caracteres (2 líneas de 16)
    type screen_array is array (0 to 31) of std_logic_vector(7 downto 0);
    signal screen_buffer : screen_array := (others => x"20"); -- Relleno con espacios (' ')
    
    -- FSM de actualización
    type state_type is (IDLE, CMD_L1, SEND_L1, CMD_L2, SEND_L2, WAIT_LCD);
    signal state        : state_type := IDLE;
    signal return_state : state_type := IDLE;
    
    signal char_index   : integer range 0 to 16 := 0;
    
    -- Timer para refrescar la pantalla a una tasa humana (ej. cada 100ms)
    constant REFRESH_MAX : integer := 10_000_000; -- Asumiendo 100MHz
    signal refresh_timer : integer := 0;
    
    signal s_char_we : std_logic := '0';
    signal s_cmd_we : std_logic := '0';

    -- Función auxiliar: Hexadecimal a ASCII
    function to_hex_ascii(hex : std_logic_vector(3 downto 0)) return std_logic_vector is
    begin
        if unsigned(hex) < 10 then
            return std_logic_vector(resize(unsigned(hex) + 48, 8)); -- '0'-'9'
        else
            return std_logic_vector(resize(unsigned(hex) - 10 + 65, 8)); -- 'A'-'F'
        end if;
    end function;

begin

    char_we <= s_char_we;
    cmd_we  <= s_cmd_we;

    -- =====================================================================
    -- PROCESO 1: FORMATEADOR LÓGICO (Genera el texto basado en la CPU)
    -- =====================================================================
    process(cpu_state, cpu_opcode, cpu_rd, cpu_data)
    begin
        -- LÍNEA 1: Mostrar la Etapa y el Opcode
        -- Ejemplo visual: "ST:EXE  OP:7F   "
        
        -- Escribimos "ST:"
        screen_buffer(0) <= x"53"; -- 'S'
        screen_buffer(1) <= x"54"; -- 'T'
        screen_buffer(2) <= x"3A"; -- ':'
        
        -- Decodificamos el estado
        case cpu_state is
            when "000" => screen_buffer(3) <= x"46"; screen_buffer(4) <= x"45"; screen_buffer(5) <= x"54"; -- "FET"
            when "001" => screen_buffer(3) <= x"44"; screen_buffer(4) <= x"45"; screen_buffer(5) <= x"43"; -- "DEC"
            when "010" => screen_buffer(3) <= x"45"; screen_buffer(4) <= x"58"; screen_buffer(5) <= x"45"; -- "EXE"
            when "011" => screen_buffer(3) <= x"4D"; screen_buffer(4) <= x"45"; screen_buffer(5) <= x"4D"; -- "MEM"
            when "100" => screen_buffer(3) <= x"57"; screen_buffer(4) <= x"42"; screen_buffer(5) <= x"20"; -- "WB "
            when others=> screen_buffer(3) <= x"3F"; screen_buffer(4) <= x"3F"; screen_buffer(5) <= x"3F"; -- "???"
        end case;
        
        -- Escribimos " OP:"
        screen_buffer(6) <= x"20"; -- ' '
        screen_buffer(7) <= x"4F"; -- 'O'
        screen_buffer(8) <= x"50"; -- 'P'
        screen_buffer(9) <= x"3A"; -- ':'
        
        -- Opcode en Hexadecimal
        screen_buffer(10) <= to_hex_ascii( '0' & cpu_opcode(6 downto 4) ); 
        screen_buffer(11) <= to_hex_ascii( cpu_opcode(3 downto 0) );
        
        -- Relleno hasta los 16 caracteres
        screen_buffer(12) <= x"20"; screen_buffer(13) <= x"20"; 
        screen_buffer(14) <= x"20"; screen_buffer(15) <= x"20";

        -- LÍNEA 2: Mostrar Registro y Datos
        -- Ejemplo visual: "R:1A  D:A5F0    "
        
        screen_buffer(16) <= x"52"; -- 'R'
        screen_buffer(17) <= x"3A"; -- ':'
        screen_buffer(18) <= to_hex_ascii( '0' & cpu_rd(4 downto 4) ); -- Bit superior
        screen_buffer(19) <= to_hex_ascii( cpu_rd(3 downto 0) );       -- 4 bits inferiores
        
        screen_buffer(20) <= x"20"; -- ' '
        screen_buffer(21) <= x"20"; -- ' '
        screen_buffer(22) <= x"44"; -- 'D'
        screen_buffer(23) <= x"3A"; -- ':'
        
        -- Dato (16 bits = 4 Nibbles Hexadecimales)
        screen_buffer(24) <= to_hex_ascii( cpu_data(15 downto 12) );
        screen_buffer(25) <= to_hex_ascii( cpu_data(11 downto 8) );
        screen_buffer(26) <= to_hex_ascii( cpu_data(7 downto 4) );
        screen_buffer(27) <= to_hex_ascii( cpu_data(3 downto 0) );
        
        -- Relleno
        screen_buffer(28) <= x"20"; screen_buffer(29) <= x"20"; 
        screen_buffer(30) <= x"20"; screen_buffer(31) <= x"20";
    end process;


    -- =====================================================================
    -- PROCESO 2: MÁQUINA DE ENVÍO AL LCD (Refresco)
    -- =====================================================================
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= IDLE;
                char_we <= '0';
                cmd_we <= '0';
                refresh_timer <= 0;
            else
                -- Valores por defecto para que generen un pulso limpio de 1 ciclo de reloj
                char_we <= '0';
                cmd_we <= '0';

                case state is
                    when IDLE =>
                        if refresh_timer < REFRESH_MAX then
                            refresh_timer <= refresh_timer + 1;
                        else
                            -- Toca refrescar la pantalla
                            refresh_timer <= 0;
                            state <= CMD_L1;
                        end if;

                    when CMD_L1 =>
                        if lcd_busy = '0' then
                            cmd_out <= x"80"; -- Comando: Forzar cursor al inicio de la Línea 1
                            cmd_we <= '1';
                            char_index <= 0;
                            return_state <= SEND_L1;
                            state <= WAIT_LCD;
                        end if;

                    when SEND_L1 =>
                        if lcd_busy = '0' then
                            if char_index < 16 then
                                char_out <= screen_buffer(char_index);
                                char_we <= '1';
                                char_index <= char_index + 1;
                                return_state <= SEND_L1;
                                state <= WAIT_LCD;
                            else
                                state <= CMD_L2;
                            end if;
                        end if;

                    when CMD_L2 =>
                        if lcd_busy = '0' then
                            cmd_out <= x"C0"; -- Comando: Forzar cursor al inicio de la Línea 2
                            cmd_we <= '1';
                            char_index <= 16;
                            return_state <= SEND_L2;
                            state <= WAIT_LCD;
                        end if;

                    when SEND_L2 =>
                        if lcd_busy = '0' then
                            if char_index < 32 then
                                char_out <= screen_buffer(char_index);
                                char_we <= '1';
                                char_index <= char_index + 1;
                                return_state <= SEND_L2;
                                state <= WAIT_LCD;
                            else
                                state <= IDLE; -- Fin del refresco completo
                            end if;
                        end if;

                    -- Estado de espera para no atropellar al controlador I2C
                    when WAIT_LCD =>
                        if lcd_busy = '1' then
                            -- Mientras esté busy, nos quedamos aquí
                            null;
                        elsif s_char_we = '0' and s_cmd_we = '0' then
                            -- Cuando se libere Y hayamos bajado nuestra señal WE, volvemos
                            state <= return_state;
                        end if;

                end case;
            end if;
        end if;
    end process;

end Behavioral;