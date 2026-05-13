library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lcd_controller is
    Port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        char_in     : in  std_logic_vector(7 downto 0);
        char_we     : in  std_logic;
        cmd_in      : in  std_logic_vector(7 downto 0);
        cmd_we      : in  std_logic;
        busy        : out std_logic;
        i2c_ena     : out std_logic;
        i2c_data    : out std_logic_vector(7 downto 0);
        i2c_busy    : in  std_logic
    );
end lcd_controller;

architecture Behavioral of lcd_controller is
    constant MS_50   : integer := 5_000_000;
    constant MS_5    : integer := 500_000;
    constant US_200  : integer := 20_000;
    constant US_50   : integer := 5_000;

    type state_type is (
        POWER_UP, 
        INIT_WAKE_SEND, INIT_WAKE_WAIT,
        INIT_SEND, INIT_WAIT, 
        IDLE, 
        NIBBLE_HIGH_EN1, NIBBLE_HIGH_EN0, 
        NIBBLE_LOW_EN1, NIBBLE_LOW_EN0,
        WAIT_I2C, WAIT_CMD
    );
    signal state : state_type := POWER_UP;
    signal return_state : state_type := IDLE;
    signal next_i2c_state : state_type := IDLE;
    
    signal delay_timer : integer := 0;
    signal delay_target: integer := 0;
    
    -- Secuencia especial de Nibbles para despertar (3, 3, 3, 2)
    type wake_nibble_array is array (0 to 3) of std_logic_vector(3 downto 0);
    type wake_wait_array is array (0 to 3) of integer;
    constant WAKE_NIBBLES : wake_nibble_array := (x"3", x"3", x"3", x"2");
    constant WAKE_WAITS   : wake_wait_array   := (MS_5, US_200, US_200, US_200);
    signal wake_idx : integer range 0 to 4 := 0;

    -- Secuencia normal de comandos (2 lines, display off, clear, entry mode, display on)
    type init_cmd_array is array (0 to 4) of std_logic_vector(7 downto 0);
    type init_wait_array is array (0 to 4) of integer;
    constant INIT_CMDS  : init_cmd_array  := (x"28", x"08", x"01", x"06", x"0C");
    constant INIT_WAITS : init_wait_array := (US_50, US_50, MS_5,  US_50, US_50);
    signal init_idx : integer range 0 to 5 := 0;
    
    signal s_i2c_ena  : std_logic := '0';
    signal s_i2c_data : std_logic_vector(7 downto 0) := x"00";
    
    signal current_byte : std_logic_vector(7 downto 0);
    signal current_nibble: std_logic_vector(3 downto 0);
    signal rs_bit       : std_logic;
    
    constant BL : std_logic := '1';
    constant RW : std_logic := '0';
begin
    i2c_ena  <= s_i2c_ena;
    i2c_data <= s_i2c_data;
    busy <= '0' when state = IDLE else '1';

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= POWER_UP;
                delay_timer <= 0;
                wake_idx <= 0;
                init_idx <= 0;
                s_i2c_ena <= '0';
            else
                case state is
                    when POWER_UP =>
                        if delay_timer < MS_50 then
                            delay_timer <= delay_timer + 1;
                        else
                            delay_timer <= 0;
                            state <= INIT_WAKE_SEND;
                        end if;

                    -- ENVIAR NIBBLES SUELTOS (Secuencia mágica de arranque)
                    when INIT_WAKE_SEND =>
                        if wake_idx < 4 then
                            current_nibble <= WAKE_NIBBLES(wake_idx);
                            rs_bit <= '0';
                            delay_target <= WAKE_WAITS(wake_idx);
                            state <= NIBBLE_HIGH_EN1; 
                            return_state <= INIT_WAKE_WAIT;
                        else
                            state <= INIT_SEND;
                        end if;

                    when INIT_WAKE_WAIT =>
                        if delay_timer < delay_target then
                            delay_timer <= delay_timer + 1;
                        else
                            delay_timer <= 0;
                            wake_idx <= wake_idx + 1;
                            state <= INIT_WAKE_SEND;
                        end if;

                    -- ENVIAR COMANDOS COMPLETOS DE INICIALIZACIÓN
                    when INIT_SEND =>
                        if init_idx < 5 then
                            current_byte <= INIT_CMDS(init_idx);
                            rs_bit <= '0';
                            delay_target <= INIT_WAITS(init_idx);
                            state <= NIBBLE_HIGH_EN1;
                            return_state <= INIT_WAIT;
                        else
                            state <= IDLE;
                        end if;
                        
                    when INIT_WAIT =>
                        if delay_timer < delay_target then
                            delay_timer <= delay_timer + 1;
                        else
                            delay_timer <= 0;
                            init_idx <= init_idx + 1;
                            state <= INIT_SEND;
                        end if;

                    when IDLE =>
                        if char_we = '1' then
                            current_byte <= char_in;
                            rs_bit <= '1';
                            state <= NIBBLE_HIGH_EN1;
                            delay_target <= US_50;
                            return_state <= WAIT_CMD;
                        elsif cmd_we = '1' then
                            current_byte <= cmd_in;
                            rs_bit <= '0';
                            state <= NIBBLE_HIGH_EN1;
                            if cmd_in = x"01" or cmd_in = x"02" then
                                delay_target <= MS_5; 
                            else
                                delay_target <= US_50;
                            end if;
                            return_state <= WAIT_CMD;
                        end if;

                    -- ENVÍO I2C
                    when NIBBLE_HIGH_EN1 =>
                        if i2c_busy = '0' and s_i2c_ena = '0' then
                            if state = INIT_WAKE_SEND or return_state = INIT_WAKE_WAIT then
                                s_i2c_data <= current_nibble & BL & '1' & RW & rs_bit;
                            else
                                s_i2c_data <= current_byte(7 downto 4) & BL & '1' & RW & rs_bit;
                            end if;
                            s_i2c_ena <= '1';
                            next_i2c_state <= NIBBLE_HIGH_EN0;
                            state <= WAIT_I2C;
                        end if;
        
                    when NIBBLE_HIGH_EN0 =>
                        if i2c_busy = '0' and s_i2c_ena = '0' then
                            if return_state = INIT_WAKE_WAIT then
                                s_i2c_data <= current_nibble & BL & '0' & RW & rs_bit;
                            else
                                s_i2c_data <= current_byte(7 downto 4) & BL & '0' & RW & rs_bit;
                            end if;
                            s_i2c_ena <= '1';
                            
                            -- Si estamos despertando, NO mandamos nibble bajo, terminamos
                            if return_state = INIT_WAKE_WAIT then
                                next_i2c_state <= return_state;
                            else
                                next_i2c_state <= NIBBLE_LOW_EN1;
                            end if;
                            state <= WAIT_I2C;
                        end if;

                    when NIBBLE_LOW_EN1 =>
                        if i2c_busy = '0' and s_i2c_ena = '0' then
                            s_i2c_data <= current_byte(3 downto 0) & BL & '1' & RW & rs_bit;
                            s_i2c_ena <= '1';
                            next_i2c_state <= NIBBLE_LOW_EN0;
                            state <= WAIT_I2C;
                        end if;

                    when NIBBLE_LOW_EN0 =>
                        if i2c_busy = '0' and s_i2c_ena = '0' then
                            s_i2c_data <= current_byte(3 downto 0) & BL & '0' & RW & rs_bit;
                            s_i2c_ena <= '1';
                            next_i2c_state <= return_state;
                            state <= WAIT_I2C;
                        end if;

                    when WAIT_I2C =>
                        if i2c_busy = '1' then
                            s_i2c_ena <= '0'; 
                        elsif i2c_busy = '0' and s_i2c_ena = '0' then
                            state <= next_i2c_state;
                        end if;
                        
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
