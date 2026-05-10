library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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
        -- === SETUP (Inicialización) ===
        0 => x"4201", -- LI R1, 1    
        1 => x"440A", -- LI R2, 10   
        2 => x"46F0", -- LI R3, 0xF0 (LEDs)
        3 => x"4800", -- LI R4, 0x00 (RAM)
        4 => x"4A05", -- LI R5, 5    

        -- === BUCLE PRINCIPAL ===
        5 => x"0248", -- ADD R1, R1, R1 (Duplicar)
        6 => x"22C0", -- SW R1, 0(R3) -> LEDs = R1
        7 => x"2300", -- SW R1, 0(R4) -> RAM[0] = R1

        8 => x"0528", -- ADD R2, R2, R5 (Sumar 5)
        
        9 => x"24C0", -- SW R2, 0(R3) -> LEDs = R2
        10=> x"2501", -- SW R2, 1(R4) -> RAM[1] = R2
        
        -- === INSTRUCCIONES DE PRUEBA ===
        11 => x"4422", -- LI R2, 0x22 (Cargar un valor de prueba, ej: 34)
        12 => x"24C2", -- SW R2, 2(R3) -> Escribe en x"00F2"
        
        -- === SALTO AL INICIO DEL BUCLE ===
        13=> x"71F9", -- JAL 5 (Volver al bucle de la línea 5)
        
        others => x"0000"
    );
begin

    instruction_out <= rom_memory(to_integer(unsigned(instruction_addr)));

end DataFlow;