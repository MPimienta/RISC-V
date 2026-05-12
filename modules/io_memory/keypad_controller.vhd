----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/12/2026 04:07:48 PM
-- Design Name: 
-- Module Name: keypad_controller - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity keypad_controller is
    Port (
        clk         : in  STD_LOGIC; 
        reset       : in  STD_LOGIC;
        keypad_col  : in  STD_LOGIC_VECTOR (3 downto 0); 
        keypad_row  : out STD_LOGIC_VECTOR (3 downto 0); 
        data_out    : out STD_LOGIC_VECTOR (15 downto 0) 
    );
end keypad_controller;

architecture Behavioral of keypad_controller is

    --constant PRESCALER_MAX : integer := 100000;
    constant PRESCALER_MAX : integer := 10;
    signal prescaler : integer range 0 to PRESCALER_MAX := 0;
    signal scan_tick : std_logic := '0';

    signal scan_row : integer range 0 to 3 := 0;
    
    signal key_value : std_logic_vector(3 downto 0) := "0000";
    signal key_valid : std_logic := '0';

    signal current_row_val : std_logic_vector(3 downto 0) := "1110";

begin
    process(clk, reset)
    begin
        if reset = '1' then
            prescaler <= 0;
            scan_tick <= '0';
        elsif rising_edge(clk) then
            if prescaler = PRESCALER_MAX then
                prescaler <= 0;
                scan_tick <= '1';
            else
                prescaler <= prescaler + 1;
                scan_tick <= '0';
            end if;
        end if;
    end process;

    process(clk, reset)
    begin
        if reset = '1' then
            scan_row <= 0;
            current_row_val <= "1110";
            key_valid <= '0';
            key_value <= "0000";
        elsif rising_edge(clk) then
            if scan_tick = '1' then
                
                if keypad_col /= "1111" then
                    key_valid <= '1';
                    -- Fila 0: 1 2 3 A
                    -- Fila 1: 4 5 6 B
                    -- Fila 2: 7 8 9 C
                    -- Fila 3: * 0 # D (Mapeados como E, 0, F, D para tener 16 valores hexadecimales)
                    
                    case current_row_val is
                        when "1110" => -- Fila 0 activa
                            if keypad_col(0)='0' then key_value <= x"1"; end if;
                            if keypad_col(1)='0' then key_value <= x"2"; end if;
                            if keypad_col(2)='0' then key_value <= x"3"; end if;
                            if keypad_col(3)='0' then key_value <= x"A"; end if;
                        when "1101" => -- Fila 1 activa
                            if keypad_col(0)='0' then key_value <= x"4"; end if;
                            if keypad_col(1)='0' then key_value <= x"5"; end if;
                            if keypad_col(2)='0' then key_value <= x"6"; end if;
                            if keypad_col(3)='0' then key_value <= x"B"; end if;
                        when "1011" => -- Fila 2 activa
                            if keypad_col(0)='0' then key_value <= x"7"; end if;
                            if keypad_col(1)='0' then key_value <= x"8"; end if;
                            if keypad_col(2)='0' then key_value <= x"9"; end if;
                            if keypad_col(3)='0' then key_value <= x"C"; end if;
                        when "0111" => -- Fila 3 activa
                            if keypad_col(0)='0' then key_value <= x"E"; end if; -- Asterisco (*)
                            if keypad_col(1)='0' then key_value <= x"0"; end if;
                            if keypad_col(2)='0' then key_value <= x"F"; end if; -- Almohadilla (#)
                            if keypad_col(3)='0' then key_value <= x"D"; end if;
                        when others => 
                            null;
                    end case;
                    
                else
                    key_valid <= '0';
                    
                    if scan_row = 3 then
                        scan_row <= 0;
                        current_row_val <= "1110";
                    else
                        scan_row <= scan_row + 1;
                        current_row_val <= current_row_val(2 downto 0) & current_row_val(3);
                    end if;
                end if;
            end if;
        end if;
    end process;

    keypad_row <= current_row_val;
    
    data_out <= "00000000000" & key_valid & key_value;

end Behavioral;
