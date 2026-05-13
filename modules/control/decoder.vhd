library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity decoder is
    Port ( 
        clk           : in std_logic;
        reset         : in std_logic;
        cpu_addr      : in std_logic_vector(15 downto 0);
        cpu_data_in   : in std_logic_vector(15 downto 0); 
        cpu_mem_write : in std_logic;
        cpu_data_out  : out std_logic_vector(15 downto 0);
        ram_data_out  : in std_logic_vector(15 downto 0); 
        ram_we        : out std_logic;
        switches_in   : in std_logic_vector(15 downto 0);
        buttons_in    : in std_logic_vector(4 downto 0);
        keypad_data_in: in std_logic_vector(15 downto 0);
        leds_out      : out std_logic_vector(15 downto 0);
        display_out   : out std_logic_vector(15 downto 0);
        -- lcd
        lcd_char_out  : out std_logic_vector(7 downto 0);
        lcd_char_we   : out std_logic;
        lcd_cmd_out   : out std_logic_vector(7 downto 0);
        lcd_cmd_we    : out std_logic;
        lcd_busy      : in  std_logic
    );
end decoder;

architecture Behavioral of decoder is

    signal leds    : std_logic_vector(15 downto 0) := (others => '0');
    signal display : std_logic_vector(15 downto 0) := (others => '0');
        
begin

    ram_we <= '1' when (cpu_mem_write = '1' and unsigned(cpu_addr) < 128) else '0';

    process(clk, reset)
    begin
        if reset = '1' then
            leds <= (others => '0');
            display <= (others => '0');
            lcd_char_out <= (others => '0');
            lcd_cmd_out <= (others => '0');
            lcd_char_we <= '0';
            lcd_cmd_we <= '0';
            
        elsif rising_edge(clk) then
            -- Por defecto, los pulsos de escritura están a 0
            lcd_char_we <= '0';
            lcd_cmd_we <= '0';
            
            if cpu_mem_write = '1' then
                if cpu_addr = x"00F0" then
                    leds <= cpu_data_in;
                elsif cpu_addr = x"00F1" then
                    display <= cpu_data_in; --eliminar luego
                elsif cpu_addr = x"00F2" then
                    lcd_char_out <= cpu_data_in(7 downto 0); -- lcd char
                    lcd_char_we  <= '1';
                elsif cpu_addr = x"00F3" then
                    lcd_cmd_out  <= cpu_data_in(7 downto 0); -- lcd cmd
                    lcd_cmd_we   <= '1';
                end if;
            end if;
        end if;
    end process;
    
    leds_out <= leds;
    display_out <= display;
    
    process(cpu_addr, ram_data_out, switches_in, buttons_in, keypad_data_in)
    begin
        if unsigned(cpu_addr) < 128 then
            cpu_data_out <= ram_data_out; 
            
        elsif cpu_addr = x"00E0" then
            cpu_data_out <= switches_in; 
            
        elsif cpu_addr = x"00E1" then
            cpu_data_out <= "00000000000" & buttons_in; --eliminar luego
            
        elsif cpu_addr = x"00E2" then
            cpu_data_out <= keypad_data_in; 
            
        elsif cpu_addr = x"00F4" then
            cpu_data_out <= "000000000000000" & lcd_busy; -- lcd busy
            
        else
            cpu_data_out <= (others => '0');
        end if;
    end process;

end Behavioral;