----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/25/2026 09:48:35 PM
-- Design Name: 
-- Module Name: rom_instructions - DataFlow
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

entity rom_instructions is
    Port (
        instruction_out     :   out std_logic_vector(15 downto 0);
        instruction_addr    :   in std_logic_vector (15 downto 0)   
    );
end rom_instructions;


architecture DataFlow of rom_instructions is

    type instruction_array is array (0 to 255) of STD_LOGIC_VECTOR(15 downto 0); -- 256 espacios de 8 bits
    
    -- De momento se deja hardcodeado, pero hay que investigar cómo cargar un programa en memoria.
    constant rom_memory : instruction_array := (
        0  => x"4E01", -- LI r7, 1   (Constante 1 para restar)
        
        -- ==========================================
        -- RETARDO GIGANTE DE 100ms (Esperar arranque LCD)
        -- ==========================================
        1  => x"42C8", -- LI r1, 200 (Contador Bucle Externo)
        2  => x"44FF", -- LI r2, 255 (Contador Bucle Medio)
        3  => x"46FF", -- LI r3, 255 (Contador Bucle Interno)
        
        4  => x"06F9", -- SUB r3, r3, r7
        5  => x"663F", -- BNE r3, r0, -1 (Salta a la instrucción 4)
        
        6  => x"04B9", -- SUB r2, r2, r7
        7  => x"643C", -- BNE r2, r0, -4 (Salta a la instrucción 3)
        
        8  => x"0279", -- SUB r1, r1, r7
        9  => x"6239", -- BNE r1, r0, -7 (Salta a la instrucción 2)
        
        -- ==========================================
        -- ENVIAR 'O' (El LCD ya está despierto)
        -- ==========================================
        10 => x"46F2", -- LI r3, 242 (LCD_DATA)
        11 => x"484F", -- LI r4, 79  ('O')
        12 => x"28C0", -- SW r4, r3, 0
        
        -- ==========================================
        -- RETARDO DE 5ms (Esperar a que I2C envíe la 'O')
        -- ==========================================
        13 => x"420A", -- LI r1, 10
        14 => x"44FF", -- LI r2, 255
        15 => x"46FF", -- LI r3, 255
        
        16 => x"06F9", -- SUB r3, r3, r7
        17 => x"663F", -- BNE r3, r0, -1 
        18 => x"04B9", -- SUB r2, r2, r7
        19 => x"643C", -- BNE r2, r0, -4
        20 => x"0279", -- SUB r1, r1, r7
        21 => x"6239", -- BNE r1, r0, -7
        
        -- ==========================================
        -- ENVIAR 'K'
        -- ==========================================
        22 => x"484B", -- LI r4, 75 ('K')
        23 => x"28C0", -- SW r4, r3, 0
        
        -- FIN (Halt)
        24 => x"7000", -- JAL r0, 0
        
        others => x"0000"
    );
begin

    instruction_out <= rom_memory(to_integer(unsigned(instruction_addr)));


end DataFlow;
