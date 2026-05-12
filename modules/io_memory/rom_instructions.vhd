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
constant MY_PROGRAM : rom_array := (
        0  => x"4670", -- LI r3, 112      (Dir. Teclado)
        1  => x"48F1", -- LI r4, 241      (Dir. 7-Seg)
        2  => x"4E10", -- LI r7, 16       (Mascara Valid Bit)
        3  => x"1AC0", -- LW r5, r3, 0    (Leer Teclado)
        4  => x"0DFA", -- AND r6, r5, r7  (Aislar Valid)
        5  => x"5C3D", -- BEQ r6, r0, -3  (Loop si no hay pulsacion)
        6  => x"4E0F", -- LI r7, 15       (Mascara Data)
        7  => x"0DFA", -- AND r6, r5, r7  (Extraer Tecla)
        8  => x"2C00", -- SW r6, r4, 0    (Escribir a 7-Seg)
        9  => x"4E10", -- LI r7, 16       (Mascara Valid Bit)
        10 => x"1AC0", -- LW r5, r3, 0    (Leer Teclado otra vez)
        11 => x"0DFA", -- AND r6, r5, r7  (Aislar Valid)
        12 => x"6C3D", -- BNE r6, r0, -3  (Loop mientras siga pulsado)
        13 => x"5035", -- BEQ r0, r0, -11 (Volver al inicio)
        14 => x"0000", -- NOP
        15 => x"0000"  -- NOP
    );

    instruction_out <= rom_memory(to_integer(unsigned(instruction_addr)));


end DataFlow;
