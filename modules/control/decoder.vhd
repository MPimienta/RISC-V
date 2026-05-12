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
        display_out   : out std_logic_vector(15 downto 0)
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
            
        elsif rising_edge(clk) then
            if cpu_mem_write = '1' then
                if cpu_addr = x"00F0" then
                    leds <= cpu_data_in;
                elsif cpu_addr = x"00F1" then
                    display <= cpu_data_in;
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
            cpu_data_out <= "00000000000" & buttons_in; 
            
        elsif cpu_addr = x"00E2" then
            cpu_data_out <= keypad_data_in; 
            
        else
            cpu_data_out <= (others => '0');
        end if;
    end process;

end Behavioral;