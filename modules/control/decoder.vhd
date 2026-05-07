----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/25/2026 09:48:35 PM
-- Design Name: 
-- Module Name: decoder - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decoder is
    Port ( 
        clk          : in std_logic;
        reset        : in std_logic;
        -- Conexiones hacia la CPU
        cpu_addr     : in std_logic_vector(15 downto 0);
        cpu_data_in  : in std_logic_vector(15 downto 0); 
        cpu_mem_write: in std_logic;
        cpu_data_out : out std_logic_vector(15 downto 0);
        -- Conexiones hacia la RAM
        ram_data_out : in std_logic_vector(15 downto 0); 
        ram_we       : out std_logic;
        -- Conexiones hacia el mundo físico
        switches_in  : in std_logic_vector(15 downto 0);
        buttons_in   : in std_logic_vector(4 downto 0);
        leds_out     : out std_logic_vector(15 downto 0);
        display_out  : out std_logic_vector(15 downto 0);
        -- Conexiones hacia el display
        lcd_we_out : out std_logic
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
            lcd_we_out <= '0';
            
        elsif rising_edge(clk) then
            lcd_we_out <= '0';
            if cpu_mem_write = '1' then
                if cpu_addr = x"00F0" then
                    leds <= cpu_data_in;
                elsif cpu_addr = x"00F1" then
                    display <= cpu_data_in;
                elsif cpu_addr = x"00F2" then
                    lcd_we_out <= '1';
                end if;
            end if;
        end if;
    end process;
    
    leds_out <= leds;
    display_out <= display;
    
    process(cpu_addr, ram_data_out, switches_in, buttons_in)
    begin
        if unsigned(cpu_addr) < 128 then
            cpu_data_out <= ram_data_out;
        elsif cpu_addr = x"00E0" then
            cpu_data_out <= switches_in;
        elsif cpu_addr = x"00E1" then
            cpu_data_out <= "00000000000" & buttons_in;
        else
            cpu_data_out <= (others => '0');
        end if;
    end process;

end Behavioral;
