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
    constant rom_memory : instruction_array := (
        
       -- ==========================================
        -- INICIALIZACIÓN DE MÁSCARAS
        -- ==========================================
        0 => x"4A10", -- LI r5, 16  (Binario: 00010000 -> Máscara para leer el bit 4 'key_valid')
        1 => x"4C0F", -- LI r6, 15  (Binario: 00001111 -> Máscara para leer los bits 0-3 'key_value')

        -- ==========================================
        -- BUCLE PRINCIPAL (POLLING DEL TECLADO)
        -- ==========================================
        -- Leer el valor del periférico
        2 => x"1222", -- LW r1, r0, -30  (0xFFE2 = -30. Carga el estado del teclado en r1)
        
        -- Comprobar si hay una tecla pulsada
        3 => x"046A", -- AND r2, r1, r5  (Aisla el bit 4 guardándolo en r2. Si no hay tecla, r2 será 0)
        4 => x"543E", -- BEQ r2, r0, -2  (Si r2 es 0, salta -2 instrucciones atrás -> Vuelve a la inst 2)
        
        -- Si llegamos aquí, ES PORQUE SE ESTÁ PULSANDO UNA TECLA
        5 => x"0672", -- AND r3, r1, r6  (Aisla el valor de la tecla 0-15 y lo guarda en r3)
        6 => x"2630", -- SW r3, r0, -16  (0xFFF0 = -16. Escribe el valor de r3 en los LEDs)
        
        -- Volver a leer para el siguiente ciclo
        7 => x"503B", -- BEQ r0, r0, -5  (Salto incondicional: r0 siempre es igual a r0. Salta a la inst 2)

        others => x"0000"
    );
begin

    instruction_out <= rom_memory(to_integer(unsigned(instruction_addr)));


end DataFlow;
