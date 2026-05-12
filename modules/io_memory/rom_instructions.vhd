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
        -- ==========================================
        -- INICIALIZACIÓN
        -- ==========================================
        0   => x"4278", -- LI r1, 120         (Inicializar Stack Pointer en dir 120)
        1   => x"4801", -- LI r4, 1           (Comando Clear LCD)
        2   => x"7466", -- JAL r2, LCD_CMD    (Llamar rutina LCD_CMD, offset +102)
        3   => x"4600", -- LI r3, 0           (Acumulador principal = 0)
        4   => x"4A00", -- LI r5, 0           (Operador guardado = 0)

        -- ==========================================
        -- INPUT_LOOP (Esperar teclas)
        -- ==========================================
        5   => x"7477", -- JAL r2, READ_KEYPAD(Llamar rutina teclado, offset +119)
        6   => x"4C0A", -- LI r6, 10          (0xA = Tecla Suma)
        7   => x"598F", -- BEQ r4, r6, OP_ADD (Si es suma, saltar a OP_ADD, offset +15)
        8   => x"4C0B", -- LI r6, 11          (0xB = Tecla Resta)
        9   => x"5995", -- BEQ r4, r6, OP_SUB (Si es resta, saltar a OP_SUB, offset +21)
        10  => x"4C0F", -- LI r6, 15          (0xF = Tecla Igual)
        11  => x"599B", -- BEQ r4, r6, OP_EQ  (Si es igual, saltar a OP_EQUAL, offset +27)

        -- Es un número (Matemáticas: Acc = Acc * 10 + tecla)
        12  => x"4C03", -- LI r6, 3           (Preparar shift x8)
        13  => x"0CF4", -- SLL r6, r3, r6     (r6 = Acc * 8)
        14  => x"4E01", -- LI r7, 1           (Preparar shift x2)
        15  => x"0EFC", -- SLL r7, r3, r7     (r7 = Acc * 2)
        16  => x"0778", -- ADD r3, r6, r7     (r3 = r6 + r7 -> Acc * 10)
        17  => x"06E0", -- ADD r3, r3, r4     (Sumar nueva tecla)
        
        -- Imprimir dígito
        18  => x"4C30", -- LI r6, 48          (ASCII '0')
        19  => x"0960", -- ADD r4, r4, r6     (Convertir a ASCII)
        20  => x"745E", -- JAL r2, LCD_CHAR   (Imprimir en pantalla)
        21  => x"71F0", -- JAL r0, INPUT_LOOP (Volver al inicio, offset -16)

        -- ==========================================
        -- OP_ADD (Suma)
        -- ==========================================
        22  => x"2640", -- SW r3, r1, 0       (Push Num1 al Stack)
        23  => x"4C01", -- LI r6, 1
        24  => x"02E1", -- SUB r1, r1, r6     (SP--)
        25  => x"4600", -- LI r3, 0           (Resetear Acumulador)
        26  => x"4A01", -- LI r5, 1           (Operador = Suma)
        27  => x"482B", -- LI r4, 43          (ASCII '+')
        28  => x"7456", -- JAL r2, LCD_CHAR   (Imprimir '+')
        29  => x"71E8", -- JAL r0, INPUT_LOOP (Volver, offset -24)

        -- ==========================================
        -- OP_SUB (Resta)
        -- ==========================================
        30  => x"2640", -- SW r3, r1, 0       (Push Num1 al Stack)
        31  => x"4C01", -- LI r6, 1
        32  => x"02E1", -- SUB r1, r1, r6     (SP--)
        33  => x"4600", -- LI r3, 0           (Resetear Acumulador)
        34  => x"4A02", -- LI r5, 2           (Operador = Resta)
        35  => x"482D", -- LI r4, 45          (ASCII '-')
        36  => x"744E", -- JAL r2, LCD_CHAR   (Imprimir '-')
        37  => x"71E0", -- JAL r0, INPUT_LOOP (Volver, offset -32)

        -- ==========================================
        -- OP_EQUAL (Ejecutar operación)
        -- ==========================================
        38  => x"4E01", -- LI r7, 1
        39  => x"02F8", -- ADD r1, r1, r7     (SP++)
        40  => x"1C40", -- LW r6, r1, 0       (Pop Num1 a r6)
        41  => x"4E01", -- LI r7, 1
        42  => x"5BC4", -- BEQ r5, r7, DO_ADD (Si operador == 1, sumar)
        43  => x"4E02", -- LI r7, 2
        44  => x"5BC4", -- BEQ r5, r7, DO_SUB (Si operador == 2, restar)
        45  => x"71D8", -- JAL r0, INPUT_LOOP (Fallback seguridad)

        -- ==========================================
        -- MATEMÁTICAS FINALES
        -- ==========================================
        -- DO_ADD
        46  => x"0738", -- ADD r3, r6, r3     (Acc = Num1 + Num2)
        47  => x"700C", -- JAL r0, SHOW_RES   (Ir a imprimir resultado)

        -- DO_SUB
        48  => x"0E7D", -- SLT r7, r6, r3     (Revisar si Num1 < Num2)
        49  => x"5E09", -- BEQ r7, r0, NO_NEG (Si es positivo, salto normal)
        50  => x"06E1", -- SUB r3, r3, r6     (Resultado absoluto negativo)
        51  => x"2640", -- SW r3, r1, 0       (Guardar resultado temporal)
        52  => x"48C0", -- LI r4, 192         (Comando mover cursor línea 2)
        53  => x"7433", -- JAL r2, LCD_CMD
        54  => x"482D", -- LI r4, 45          (Imprimir signo '-')
        55  => x"743B", -- JAL r2, LCD_CHAR
        56  => x"1640", -- LW r3, r1, 0       (Restaurar resultado)
        57  => x"7006", -- JAL r0, FMT_RES    (Ir a formato)

        -- NO_NEG
        58  => x"0739", -- SUB r3, r6, r3     (Acc = Num1 - Num2)

        -- SHOW_RES
        59  => x"2640", -- SW r3, r1, 0       (Guardar resultado temporal)
        60  => x"48C0", -- LI r4, 192         (Comando línea 2)
        61  => x"742B", -- JAL r2, LCD_CMD
        62  => x"1640", -- LW r3, r1, 0       (Restaurar)

        -- FMT_RES
        63  => x"7402", -- JAL r2, PRT_DEC    (Imprimir número binario en decimal)
        64  => x"7000", -- JAL r0, 0          (Bucle infinito de fin de programa)

        -- ==========================================
        -- RUTINA PRINT_DECIMAL (Módulo y Divisiones)
        -- ==========================================
        65  => x"2440", -- SW r2, r1, 0       (Guardar RA)
        66  => x"4C01", -- LI r6, 1
        67  => x"02E1", -- SUB r1, r1, r6     (SP--)
        68  => x"4CFF", -- LI r6, 255         (Marcador fin de dígitos)
        69  => x"2C40", -- SW r6, r1, 0       (Push marcador)
        70  => x"4C01", -- LI r6, 1
        71  => x"02E1", -- SUB r1, r1, r6     (SP--)

        -- extract_loop:
        72  => x"4800", -- LI r4, 0           (Cociente = 0)
        73  => x"4A0A", -- LI r5, 10          (Divisor = 10)
        
        -- div_loop:
        74  => x"0CDD", -- SLT r6, r3, r5     (¿Queda menos de 10?)
        75  => x"6C05", -- BNE r6, r0, div_end(Si sí, fin división)
        76  => x"06D1", -- SUB r3, r3, r5     (Restar 10)
        77  => x"4C01", -- LI r6, 1
        78  => x"0960", -- ADD r4, r4, r6     (Cociente++)
        79  => x"71FB", -- JAL r0, div_loop   (Loop división)

        -- div_end:
        80  => x"2640", -- SW r3, r1, 0       (Push dígito extraído)
        81  => x"4C01", -- LI r6, 1
        82  => x"02E1", -- SUB r1, r1, r6     (SP--)
        83  => x"0700", -- ADD r3, r4, r0     (Mover cociente a r3 para próxima ronda)
        84  => x"6634", -- BNE r3, r0, ext_lp (Si cociente != 0, extraer siguiente)

        -- prt_loop: (Desapilar e imprimir)
        85  => x"4C01", -- LI r6, 1
        86  => x"02E0", -- ADD r1, r1, r6     (SP++)
        87  => x"1840", -- LW r4, r1, 0       (Pop dígito)
        88  => x"4CFF", -- LI r6, 255         (Comprobar si es el marcador de fin)
        89  => x"5985", -- BEQ r4, r6, prt_end
        90  => x"4C30", -- LI r6, 48          (ASCII '0')
        91  => x"0960", -- ADD r4, r4, r6     (Convertir dígito a ASCII)
        92  => x"7416", -- JAL r2, LCD_CHAR   (Imprimir)
        93  => x"71F8", -- JAL r0, prt_loop   (Siguiente dígito)

        -- prt_end:
        94  => x"4C01", -- LI r6, 1
        95  => x"02E0", -- ADD r1, r1, r6     (SP++)
        96  => x"1440", -- LW r2, r1, 0       (Restaurar RA)
        97  => x"8080", -- JALR r0, r2, 0     (Retorno de subrutina)

        -- ==========================================
        -- DRIVERS DE HARDWARE (MMIO)
        -- ==========================================
        -- WAIT_LCD:
        98  => x"4EF4", -- LI r7, 244         (0x00F4 Dir. LCD Busy)
        99  => x"1DC0", -- w_loop: LW r6, r7, 0 
        100 => x"4A01", -- LI r5, 1
        101 => x"0DAA", -- AND r6, r6, r5     (Aislar bit 0)
        102 => x"6C3D", -- BNE r6, r0, w_loop (Esperar mientras Busy == 1)
        103 => x"8080", -- JALR r0, r2, 0

        -- LCD_CMD:
        104 => x"2440", -- SW r2, r1, 0       (Guardar RA)
        105 => x"4C01", -- LI r6, 1
        106 => x"02E1", -- SUB r1, r1, r6
        107 => x"75F7", -- JAL r2, WAIT_LCD
        108 => x"4EF3", -- LI r7, 243         (0x00F3 Dir. LCD Cmd)
        109 => x"29C0", -- SW r4, r7, 0       (Ejecutar Comando)
        110 => x"4C01", -- LI r6, 1
        111 => x"02E0", -- ADD r1, r1, r6
        112 => x"1440", -- LW r2, r1, 0       (Restaurar RA)
        113 => x"8080", -- JALR r0, r2, 0

        -- LCD_CHAR:
        114 => x"2440", -- SW r2, r1, 0       (Guardar RA)
        115 => x"4C01", -- LI r6, 1
        116 => x"02E1", -- SUB r1, r1, r6
        117 => x"75ED", -- JAL r2, WAIT_LCD
        118 => x"4EF2", -- LI r7, 242         (0x00F2 Dir. LCD Data)
        119 => x"29C0", -- SW r4, r7, 0       (Escribir Carácter)
        120 => x"4C01", -- LI r6, 1
        121 => x"02E0", -- ADD r1, r1, r6
        122 => x"1440", -- LW r2, r1, 0       (Restaurar RA)
        123 => x"8080", -- JALR r0, r2, 0

        -- READ_KEYPAD:
        124 => x"4EE2", -- LI r7, 226         (0x00E2 Dir. Keypad)
        125 => x"1DC0", -- r_press: LW r6, r7, 0
        126 => x"4A10", -- LI r5, 16          (Valid Flag = Bit 4)
        127 => x"09AA", -- AND r4, r6, r5
        128 => x"583D", -- BEQ r4, r0, r_press(Loop si no hay tecla)
        129 => x"4A0F", -- LI r5, 15          (Máscara Bits 0-3)
        130 => x"09AA", -- AND r4, r6, r5     (Guardar Valor)
        131 => x"1DC0", -- r_rel: LW r6, r7, 0
        132 => x"4A10", -- LI r5, 16
        133 => x"0DAA", -- AND r6, r6, r5
        134 => x"6C3D", -- BNE r6, r0, r_rel  (Loop hasta que se suelte la tecla)
        135 => x"8080", -- JALR r0, r2, 0

        others => x"0000"
    );
begin

    instruction_out <= rom_memory(to_integer(unsigned(instruction_addr)));


end DataFlow;
