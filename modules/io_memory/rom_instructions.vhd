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
        
        -- ==========================================
        -- 1. SETUP E INICIALIZACIÓN
        -- ==========================================
        0 => x"47F0", -- LI R3, -16    -> Base PANTALLA (0xFFF0)
        1 => x"4DE0", -- LI R6, -32    -> Base TECLADO  (0xFFE0)
        
        -- EL TRUCO MATEMÁTICO: Sumamos 32 (0x20) en lugar de 48
        2 => x"4820", -- LI R4, 32     -> Offset ASCII ('0' = 0x20 + valid_bit)
        
        3 => x"4201", -- LI R1, 1      -> Máscara "OLED Busy"
        
        -- ==========================================
        -- 2. ESPERAR PULSACIÓN DEL TECLADO
        -- ==========================================
        -- Bucle WAIT_PRESS
        4 => x"3B82", -- LW R5, 2(R6)   -> Leer Teclado (0xFFE2)
        5 => x"5A3F", -- BEQ R5, R0, -1 -> Si es 0x0000 (valid=0), repite línea 4
        
        -- ==========================================
        -- 3. PROCESAR DATO (Aprovechando el key_valid)
        -- ==========================================
        6 => x"0B60", -- ADD R5, R5, R4 -> R5 = 0x0012 + 0x0020 = 0x0032 ('2')
        
        -- ==========================================
        -- 4. ESPERAR A QUE LA OLED ESTÉ LIBRE
        -- ==========================================
        -- Bucle WAIT_OLED
        7 => x"3EC4", -- LW R7, 4(R3)   -> Leer Estado OLED (0xFFF4)
        8 => x"5E7F", -- BEQ R7, R1, -1 -> Si R7 == 1 (Busy), repite línea 7
        
        -- ==========================================
        -- 5. ESCRIBIR EN LA PANTALLA OLED
        -- ==========================================
        9 => x"2AC3", -- SW R5, 3(R3)   -> Escribir en OLED Data (0xFFF3)
        
        -- ==========================================
        -- 6. ESPERAR A SOLTAR LA TECLA (Antirrebote Lógico)
        -- ==========================================
        -- Bucle WAIT_RELEASE
        10=> x"3B82", -- LW R5, 2(R6)   -> Leer Teclado de nuevo
        11=> x"6A3F", -- BNE R5, R0, -1 -> Si NO es 0x0000 (sigue pulsado), repite línea 10
        
        -- ==========================================
        -- 7. VOLVER AL INICIO
        -- ==========================================
        12=> x"71F7", -- JAL -9         -> Saltar de vuelta a la línea 4

        others => x"0000"
    );
begin

    instruction_out <= rom_memory(to_integer(unsigned(instruction_addr)));


end DataFlow;
