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
    
    signal op1 : unsigned(3 downto 0);
    signal op2 : unsigned(3 downto 0);
    signal res_signed : signed (7 downto 0);

    -- Señales para conversión binario -> decimal
    signal res_abs : integer range 0 to 127;
    signal tens : integer range 0 to 9;
    signal units_d : integer range 0 to 9;
    signal is_neg : std_logic;

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
    led_activating_counter <= std_logic_vector(refresh_counter(19 downto 18));
    
     --comentar para implementación
    --led_activating_counter <= std_logic_vector(refresh_counter(3 downto 2));
    
    op1 <= unsigned(data_in(15 downto 12));
    op2 <= unsigned(data_in(11 downto 8));
    res_signed <= signed(data_in(7 downto 0));
    
    res_abs <= to_integer(abs(res_signed));
    is_neg <= '1' when res_signed < 0 else '0';
    
    tens <= res_abs / 10;
    units_d <= res_abs mod 10;

    -- Multiplexor para activar los ánodos (encendemos un display a la vez)
process(led_activating_counter, op1, op2, tens, units_d, is_neg)
    variable digit_val : integer range 0 to 15;
    begin
        seg <= "1111111";
        digit_val := 15;
        
        case led_activating_counter is
            when "00" =>
                an <= "0111";
                digit_val := to_integer(op1);
            when "01" =>
                an <= "1011";
                digit_val := to_integer(op2);
            when "10" =>
                an <= "1101";
                if is_neg = '1' then
                    seg <= "0111111";
                    digit_val := 15;
                elsif tens > 0 then
                    digit_val := tens;
                else 
                    seg <= "1111111";
                    digit_val := 15;
                end if;
            when "11" =>
                an <= "1110";
                digit_val := units_d;
            when others => an <= "1111";
        end case;
        
        if digit_val = 0 then seg <= "1000000";
        elsif digit_val = 1 then seg <= "1111001";
        elsif digit_val = 2 then seg <= "0100100";
        elsif digit_val = 3 then seg <= "0110000";
        elsif digit_val = 4 then seg <= "0011001";
        elsif digit_val = 5 then seg <= "0010010";
        elsif digit_val = 6 then seg <= "0000010";
        elsif digit_val = 7 then seg <= "1111000";
        elsif digit_val = 8 then seg <= "0000000";
        elsif digit_val = 9 then seg <= "0010000";
        end if;
        
    end process;

   
    -- Apagamos el punto decimal
    dp <= '1';

end Behavioral;
