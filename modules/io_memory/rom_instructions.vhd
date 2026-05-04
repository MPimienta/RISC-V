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
        instruction_out     :   out std_logic_vector(7 downto 0);
        instruction_addr    :   in std_logic_vector (7 downto 0)   
    );
end rom_instructions;


architecture DataFlow of rom_instructions is

    type instruction_array is array (0 to 255) of STD_LOGIC_VECTOR(7 downto 0); -- 256 espacios de 8 bits
    
    -- De momento se deja hardcodeado, pero hay que investigar cómo cargar un programa en memoria.
    constant rom_memory   :   instruction_array   := (
        -- === SETUP INICIAL ===
        -- Instrucción 0: LI R5, 0xE8 
        -- Base para escribir R1 (offset 8). 0xE8 + 8 = 0xF0
        0 => x"4A", 1 => x"E8", 
        
        -- Instrucción 2: LI R6, 0xE0 
        -- Base para escribir R2 (offset 16). 0xE0 + 16 = 0xF0
        2 => x"4C", 3 => x"E0", 

        -- Instrucción 4: LI R1, 0xCC 
        -- Carga el Patrón 1: 11001100
        4 => x"42", 5 => x"CC", 
        
        -- Instrucción 6: LI R2, 0x33 
        -- Carga el Patrón 2: 00110011
        6 => x"44", 7 => x"33", 

        -- === INICIO DEL BUCLE INFITNITO ===
        -- Instrucción 8: SW R1, 8(R5) 
        -- Enciende los LEDs con el Patrón 1 (0xCC)
        8 => x"21", 9 => x"48", 
        
        -- Instrucción 10: ADD R0, R0, R0 (NOP)
        -- Pequeña pausa para la simulación
        10=> x"00", 11=> x"00", 
        
        -- Instrucción 12: SW R2, 16(R6) 
        -- Enciende los LEDs con el Patrón 2 (0x33)
        12=> x"21", 13=> x"90", 
        
        -- Instrucción 14: ADD R0, R0, R0 (NOP)
        -- Pequeña pausa
        14=> x"00", 15=> x"00", 
        
        -- Instrucción 16: JAL 0x08 
        -- Salto incondicional de vuelta a la instrucción 8.
        -- Matemáticas del salto: Target(8) - PC actual en ejecución(18) = -10 (0xF6)
        16=> x"70", 17=> x"F6", 

        others => x"00"
    );

begin

    instruction_out <= rom_memory(to_integer(unsigned(instruction_addr)));


end DataFlow;
