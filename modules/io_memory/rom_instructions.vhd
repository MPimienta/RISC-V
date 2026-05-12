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
constant rom_memory   :   instruction_array   := (
        -- === FASE 1: SETUP DE DIRECCIONES ===
        0 => x"42E0", -- LI R1, 0xE0 (Dirección Base Switches: 11100000)
        1 => x"44F0", -- LI R2, 0xF0 (Dirección Base LEDs:    11110000)
        2 => x"4600", -- LI R3, 0x00 (Dirección Base RAM)

        -- === FASE 2: TEST DE FORWARDING (EX->EX y MEM->EX) ===
        -- Si el forwarding falla, estas sumas darán basura.
        3 => x"4805", -- LI R4, 5
        4 => x"0B20", -- ADD R5, R4, R4   -> R5 = 10 (Requiere Forwarding MEM->EX)
        5 => x"0D61", -- SUB R6, R5, R4   -> R6 = 5  (Requiere Forwarding EX->EX)
        6 => x"0D76", -- XOR R6, R5, R6   -> R6 = 10 ^ 5 = 15

        -- === FASE 3: TEST DE MEMORIA Y LOAD-USE HAZARD ===
        7 => x"2CC0", -- SW R6, 0(R3)     -> RAM[0] = 15
        8 => x"1EC0", -- LW R7, 0(R3)     -> R7 = RAM[0] = 15
        -- ¡ATENCIÓN! La siguiente instrucción usa R7 inmediatamente.
        -- La Hazard Unit DEBE congelar el PC 1 ciclo (Burbuja) aquí.
        
        -- ARREGLO MATEMÁTICO: Ahora suma +1 puro
        9 => x"3FC1", -- ADDI R7, R7, 1   -> R7 = 16 

        -- === FASE 4: TEST DE CONTROL HAZARD (FLUSH POR SALTO) ===
        10=> x"4810", -- LI R4, 16
        11=> x"5F03", -- BEQ R7, R4, +3   -> Como 16 == 16, SALTA a la inst 14.
        -- Estas dos instrucciones entrarán al tubo, pero el FLUSH debe matarlas (volverlas 0).
        12=> x"0FE0", -- ADD R7, R7, R7   -> Si se ejecuta por error, R7 = 32 (MAL)
        13=> x"0FE0", -- ADD R7, R7, R7   -> Si se ejecuta por error, R7 = 64 (MAL)
        
        -- (Destino del BEQ)
        -- ARREGLO MATEMÁTICO: Ahora suma +16 puro
        14=> x"3FD0", -- ADDI R7, R7, 16  -> R7 = 16 + 16 = 32 (Hex: 0x0020)

        -- === FASE 5: TEST DE JAL ===
        15=> x"7003", -- JAL R0, +3       -> Salta incondicionalmente a la inst 18.
        16=> x"0000", -- NOP (Se vacía por el flush)
        17=> x"0000", -- NOP (Se vacía por el flush)

        -- === FASE 6: ESCRITURA DE CONFIRMACIÓN ===
        -- Si TODO el pipeline ha funcionado perfecto, R7 vale exactamente 32.
        18=> x"2E80", -- SW R7, 0(R2)     -> LEDs = 32 (Se encenderá el LED número 5)

        -- === FASE 7: BUCLE INFINITO DE ECO (Switches a LEDs) ===
        19=> x"1A40", -- LW R5, 0(R1)     -> Lee los Switches
        20=> x"2A80", -- SW R5, 0(R2)     -> Escribe en los LEDs
        21=> x"71FE", -- JAL R0, -2       -> Vuelve a la instrucción 19 (Loop infinito)

        others => x"0000"
    );
begin

    instruction_out <= rom_memory(to_integer(unsigned(instruction_addr)));


end DataFlow;
