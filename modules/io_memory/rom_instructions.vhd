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

    type instruction_array is array (0 to 2047) of STD_LOGIC_VECTOR(15 downto 0); -- 256 espacios de 8 bits
    
    -- De momento se deja hardcodeado, pero hay que investigar cómo cargar un programa en memoria.
constant rom_memory   :   instruction_array   := (
        -- === SETUP (Inicialización) ===
        0 => x"4201", -- LI R1, 1    
        1 => x"440A", -- LI R2, 10   
        
        -- CORRECCIÓN: LI R3, -16 (Al extender el signo, R3 se convierte en 0xFFF0)
        2 => x"47F0", -- LI R3, -16  -> Base para Periféricos de Salida
        
        3 => x"4800", -- LI R4, 0x00 -> Base para RAM
        4 => x"4A05", -- LI R5, 5    

        -- === BUCLE PRINCIPAL ===
        5 => x"0248", -- ADD R1, R1, R1 (Duplicar)
        
        -- Escribir en Periféricos
        6 => x"22C0", -- SW R1, 0(R3) -> LEDs = R1 (Dirección 0xFFF0 + 0 = 0xFFF0)
        -- Truco: Si quisieras escribir R1 en el Display (0xFFF1), usarías un offset de 1:
        -- SW R1, 1(R3) -> x"22C1" 

        -- Escribir en RAM
        7 => x"2300", -- SW R1, 0(R4) -> RAM[0] = R1

        8 => x"04A8", -- ADD R2, R2, R5 (Sumar 5)
        
        9 => x"24C0", -- SW R2, 0(R3) -> LEDs = R2
        10=> x"2501", -- SW R2, 1(R4) -> RAM[1] = R2

        11=> x"71F9", -- JAL 5 (Volver al bucle)

        others => x"0000"
    );
begin

    instruction_out <= rom_memory(to_integer(unsigned(instruction_addr)));


end DataFlow;
