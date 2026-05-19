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
        clk      : in  std_logic;                    -- Reloj de 100 MHz de la placa
        reset    : in  std_logic;                    -- Reset global
        data_in  : in  std_logic_vector(15 downto 0); -- Dato de 16 bits a mostrar (ej. el PC)
        seg      : out std_logic_vector(6 downto 0); -- Segmentos A-G
        dp       : out std_logic;                    -- Punto decimal
        an       : out std_logic_vector(3 downto 0)  -- Ánodos de los 4 displays
    );
end seven_seg_decoder;

architecture Behavioral of seven_seg_decoder is

    -- Señales para el divisor de reloj (para el refresco de los displays)
    signal refresh_counter : unsigned(19 downto 0) := (others => '0');
    signal led_activating_counter : std_logic_vector(1 downto 0);

    -- Señales para decodificar el dígito actual
    signal current_digit : std_logic_vector(3 downto 0);

begin

    -- Divisor de frecuencia para el refresco (multiplexación) de los displays
    -- Necesitamos una frecuencia lo suficientemente rápida para que no parpadee (ej. 1 kHz)
    process(clk, reset)
    begin
        if reset = '1' then
            refresh_counter <= (others => '0');
        elsif rising_edge(clk) then
            refresh_counter <= refresh_counter + 1;
        end if;
    end process;

    -- Usamos los bits superiores del contador para cambiar de display
    --led_activating_counter <= std_logic_vector(refresh_counter(19 downto 18));
    
    -- comentar para implementación
    led_activating_counter <= std_logic_vector(refresh_counter(3 downto 2));

    -- Multiplexor para activar los ánodos (encendemos un display a la vez)
process(led_activating_counter, data_in) -- <-- Añade data_in a la lista sensible
    begin
        case led_activating_counter is
            when "00" =>
                an <= "0111"; 
                current_digit <= data_in(15 downto 12);
            when "01" =>
                an <= "1011"; 
                current_digit <= data_in(11 downto 8);
            when "10" =>
                an <= "1101"; 
                current_digit <= data_in(7 downto 4);
            when "11" =>
                an <= "1110"; 
                current_digit <= data_in(3 downto 0);
            when others =>
                an <= "1111";
                current_digit <= "0000"; -- <-- ESTO por seguridad
        end case;
    end process;

    -- Decodificador BCD a 7 Segmentos (Ánodo Común: 0 = Encendido, 1 = Apagado)
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

    -- Apagamos el punto decimal
    dp <= '1';

end Behavioral;
