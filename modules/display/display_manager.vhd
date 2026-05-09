library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity display_manager is
    Port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        
        -- Datos provenientes de la CPU (Simplificados)
        cpu_opcode  : in  std_logic_vector(6 downto 0);
        cpu_reg     : in  std_logic_vector(4 downto 0);
        cpu_val     : in  std_logic_vector(15 downto 0);
        
        -- Interfaz hacia el LCD Driver
        lcd_busy    : in  std_logic;
        char_out    : out std_logic_vector(7 downto 0);
        char_we     : out std_logic;
        cmd_out     : out std_logic_vector(7 downto 0);
        cmd_we      : out std_logic
    );
end display_manager;

architecture Behavioral of display_manager is

    type screen_array is array (0 to 31) of std_logic_vector(7 downto 0);
    signal screen_buffer : screen_array := (others => x"20");
    
    type state_type is (IDLE, CMD_L1, SEND_L1, CMD_L2, SEND_L2, WAIT_LCD);
    signal state        : state_type := IDLE;
    signal return_state : state_type := IDLE;
    
    signal char_index   : integer range 0 to 32 := 0;
    
    signal s_char_we    : std_logic := '0';
    signal s_cmd_we     : std_logic := '0';

    -- Timer para refrescar la pantalla (Ej: 10 millones = 100ms a 100MHz)
    constant REFRESH_MAX : integer := 10_000_000; 
    signal refresh_timer : integer := 0;

    function to_hex_ascii(hex : std_logic_vector(3 downto 0)) return std_logic_vector is
    begin
        if unsigned(hex) < 10 then
            return std_logic_vector(resize(unsigned(hex) + 48, 8));
        else
            return std_logic_vector(resize(unsigned(hex) - 10 + 65, 8));
        end if;
    end function;

begin

    char_we <= s_char_we;
    cmd_we  <= s_cmd_we;

    -- =====================================================================
    -- PROCESO 1: FORMATEADOR LÓGICO
    -- =====================================================================
    process(cpu_opcode, cpu_reg, cpu_val)
    begin
        -- LÍNEA 1: "OPCODE: XX      "
        screen_buffer(0) <= x"4F"; -- 'O'
        screen_buffer(1) <= x"50"; -- 'P'
        screen_buffer(2) <= x"43"; -- 'C'
        screen_buffer(3) <= x"4F"; -- 'O'
        screen_buffer(4) <= x"44"; -- 'D'
        screen_buffer(5) <= x"45"; -- 'E'
        screen_buffer(6) <= x"3A"; -- ':'
        screen_buffer(7) <= x"20"; -- ' '
        
        screen_buffer(8) <= to_hex_ascii('0' & cpu_opcode(6 downto 4));
        screen_buffer(9) <= to_hex_ascii(cpu_opcode(3 downto 0));
        
        for i in 10 to 15 loop screen_buffer(i) <= x"20"; end loop;

        -- LÍNEA 2: "REG:XX VAL:XXXX "
        screen_buffer(16) <= x"52"; -- 'R'
        screen_buffer(17) <= x"45"; -- 'E'
        screen_buffer(18) <= x"47"; -- 'G'
        screen_buffer(19) <= x"3A"; -- ':'
        
        screen_buffer(20) <= to_hex_ascii("000" & cpu_reg(4));
        screen_buffer(21) <= to_hex_ascii(cpu_reg(3 downto 0));
        
        screen_buffer(22) <= x"20"; -- ' '
        
        screen_buffer(23) <= x"56"; -- 'V'
        screen_buffer(24) <= x"41"; -- 'A'
        screen_buffer(25) <= x"4C"; -- 'L'
        screen_buffer(26) <= x"3A"; -- ':'
        
        screen_buffer(27) <= to_hex_ascii(cpu_val(15 downto 12));
        screen_buffer(28) <= to_hex_ascii(cpu_val(11 downto 8));
        screen_buffer(29) <= to_hex_ascii(cpu_val(7 downto 4));
        screen_buffer(30) <= to_hex_ascii(cpu_val(3 downto 0));
        
        screen_buffer(31) <= x"20"; -- ' '
    end process;

    -- =====================================================================
    -- PROCESO 2: MÁQUINA DE ENVÍO AL LCD (FSM)
    -- =====================================================================
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= IDLE;
                s_char_we <= '0';
                s_cmd_we <= '0';
                refresh_timer <= 0;
            else
                s_char_we <= '0';
                s_cmd_we <= '0';

                case state is
                    when IDLE =>
                        if refresh_timer < REFRESH_MAX then
                            refresh_timer <= refresh_timer + 1;
                        else
                            refresh_timer <= 0;
                            state <= CMD_L1;
                        end if;

                    when CMD_L1 =>
                        if lcd_busy = '0' then
                            cmd_out <= x"80";
                            s_cmd_we <= '1';
                            char_index <= 0;
                            return_state <= SEND_L1;
                            state <= WAIT_LCD;
                        end if;

                    when SEND_L1 =>
                        if lcd_busy = '0' then
                            if char_index < 16 then
                                char_out <= screen_buffer(char_index);
                                s_char_we <= '1';
                                char_index <= char_index + 1;
                                return_state <= SEND_L1;
                                state <= WAIT_LCD;
                            else
                                state <= CMD_L2;
                            end if;
                        end if;

                    when CMD_L2 =>
                        if lcd_busy = '0' then
                            cmd_out <= x"C0";
                            s_cmd_we <= '1';
                            char_index <= 16;
                            return_state <= SEND_L2;
                            state <= WAIT_LCD;
                        end if;

                    when SEND_L2 =>
                        if lcd_busy = '0' then
                            if char_index < 32 then
                                char_out <= screen_buffer(char_index);
                                s_char_we <= '1';
                                char_index <= char_index + 1;
                                return_state <= SEND_L2;
                                state <= WAIT_LCD;
                            else
                                state <= IDLE;
                            end if;
                        end if;

                    when WAIT_LCD =>
                        if lcd_busy = '1' then
                            null;
                        elsif s_char_we = '0' and s_cmd_we = '0' then
                            state <= return_state;
                        end if;
                end case;
            end if;
        end if;
    end process;
end Behavioral;