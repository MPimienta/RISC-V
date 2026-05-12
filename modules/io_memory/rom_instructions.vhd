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
# --- INICIALIZACIÓN ---
0:  LI r3, 226       # r3 = 0xE2 (Dir. Teclado)
1:  LI r4, 240       # r4 = 0xF0 (Dir. LEDs)

# --- ESPERAR PULSACIÓN ---
2:  LI r7, 16        # r7 = 16 (Máscara para el Bit 4 'Valid')
3:  LW r5, r3, 0     # r5 = Memoria[r3] (Leer Teclado)
4:  AND r6, r5, r7   # r6 = r5 AND r7 (Aislar el Bit 4)
5:  BEQ r6, r0, -3   # Si r6 == 0, salta -3 (vuelve a la línea 2)

# --- PROCESAR TECLA ---
6:  LI r7, 15        # r7 = 15 (Máscara para aislar los bits 3 a 0)
7:  AND r6, r5, r7   # r6 = r5 AND 15 (Nos quedamos con el valor de la tecla)
8:  SW r6, r4, 0     # Memoria[r4] = r6 (¡Escribir en los LEDs!)

# --- ESPERAR A QUE SUELTE LA TECLA ---
9:  LI r7, 16        # r7 = 16
10: LW r5, r3, 0     # r5 = Leer Teclado
11: AND r6, r5, r7   # r6 = Aislar el Bit Valid
12: BNE r6, r0, -3   # Si r6 != 0 (sigue pulsado), salta -3 (vuelve a la línea 9)

# --- REPETIR CICLO ---
13: BEQ r0, r0, -11  # Salto incondicional al inicio (vuelve a la línea 2)
    );

    instruction_out <= rom_memory(to_integer(unsigned(instruction_addr)));


end DataFlow;
