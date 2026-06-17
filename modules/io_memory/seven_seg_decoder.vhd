----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/03/2026 05:54:14 PM
-- Design Name: 
-- Module Name: seven_seg_decoder - DataFlow
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

entity seven_seg_decoder is
    Port (
        clk      : in  std_logic;
        reset    : in  std_logic;   
        data_in  : in  std_logic_vector(15 downto 0); 
        seg      : out std_logic_vector(6 downto 0); 
        dp       : out std_logic;                 
        an       : out std_logic_vector(3 downto 0)  
    );
end seven_seg_decoder;

architecture Behavioral of seven_seg_decoder is

    signal refresh_counter : unsigned(19 downto 0) := (others => '0'); -- divisor para multiplexacion de displays
    signal led_activating_counter : std_logic_vector(1 downto 0);
    signal current_digit : std_logic_vector(3 downto 0);

begin

    process(clk, reset)
    begin
        if reset = '1' then
            refresh_counter <= (others => '0');
        elsif rising_edge(clk) then
            refresh_counter <= refresh_counter + 1;
        end if;
    end process;

    -- Comentar para simulación
    --led_activating_counter <= std_logic_vector(refresh_counter(19 downto 18));
    
    -- comentar para implementación
    led_activating_counter <= std_logic_vector(refresh_counter(3 downto 2));

process(led_activating_counter, data_in) 
    begin
        case led_activating_counter is
            when "00" =>
                an <= "0111"; -- display 3
                current_digit <= data_in(15 downto 12);
            when "01" =>
                an <= "1011"; -- display 2
                current_digit <= data_in(11 downto 8);
            when "10" =>
                an <= "1101"; -- display 1
                current_digit <= data_in(7 downto 4);
            when "11" =>
                an <= "1110"; -- display 0
                current_digit <= data_in(3 downto 0);
            when others =>
                an <= "1111";
                current_digit <= "0000"; 
        end case;
    end process;

    process(current_digit)
    begin
        case current_digit is
            when "0000" => seg <= "1000000"; -- 0
            when "0001" => seg <= "1111001"; -- 1
            when "0010" => seg <= "0100100"; -- 2
            when "0011" => seg <= "0110000"; -- 3
            when "0100" => seg <= "0011001"; -- 4
            when "0101" => seg <= "0010010"; -- 5
            when "0110" => seg <= "0000010"; -- 6
            when "0111" => seg <= "1111000"; -- 7
            when "1000" => seg <= "0000000"; -- 8
            when "1001" => seg <= "0010000"; -- 9
            when "1010" => seg <= "0001000"; -- A
            when "1011" => seg <= "0000011"; -- b
            when "1100" => seg <= "1000110"; -- C
            when "1101" => seg <= "0100001"; -- d
            when "1110" => seg <= "0000110"; -- E
            when "1111" => seg <= "0001110"; -- F
            when others => seg <= "1111111"; -- Apagado
        end case;
    end process;

    dp <= '1';

end Behavioral;
