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
        -- INICIALIZACIÓN
        0   => x"4278", -- LI r1, 120
        1   => x"4801", -- LI r4, 1
        2   => x"7466", -- JAL r2, LCD_CMD
        3   => x"4600", -- LI r3, 0
        4   => x"4A00", -- LI r5, 0

        -- BUCLE PRINCIPAL
        5   => x"7477", -- JAL r2, READ_KEYPAD
        6   => x"4C0A", -- LI r6, 10
        7   => x"598F", -- BEQ r4, r6, OP_ADD
        8   => x"4C0B", -- LI r6, 11
        9   => x"5995", -- BEQ r4, r6, OP_SUB
        10  => x"4C0F", -- LI r6, 15
        11  => x"599B", -- BEQ r4, r6, OP_EQ 

        -- MATEMÁTICAS
        12  => x"4C03", -- LI r6, 3
        13  => x"0CF4", -- SLL r6, r3, r6
        14  => x"4E01", -- LI r7, 1
        15  => x"0EFC", -- SLL r7, r3, r7
        16  => x"07B8", -- ADD r3, r6, r7
        17  => x"06E0", -- ADD r3, r3, r4
        
        -- IMPRIMIR DÍGITO
        18  => x"4C30", -- LI r6, 48
        19  => x"0930", -- ADD r4, r4, r6
        20  => x"745E", -- JAL r2, LCD_CHAR
        21  => x"71F0", -- JAL r0, INPUT_LOOP

        -- OP_ADD
        22  => x"2640", -- SW r3, r1, 0
        23  => x"4C01", -- LI r6, 1
        24  => x"0271", -- SUB r1, r1, r6
        25  => x"4600", -- LI r3, 0
        26  => x"4A01", -- LI r5, 1
        27  => x"482B", -- LI r4, 43
        28  => x"7456", -- JAL r2, LCD_CHAR
        29  => x"71E8", -- JAL r0, INPUT_LOOP

        -- OP_SUB
        30  => x"2640", -- SW r3, r1, 0
        31  => x"4C01", -- LI r6, 1
        32  => x"0271", -- SUB r1, r1, r6
        33  => x"4600", -- LI r3, 0
        34  => x"4A02", -- LI r5, 2
        35  => x"482D", -- LI r4, 45
        36  => x"744E", -- JAL r2, LCD_CHAR
        37  => x"71E0", -- JAL r0, INPUT_LOOP

        -- OP_EQUAL
        38  => x"4E01", -- LI r7, 1
        39  => x"0278", -- ADD r1, r1, r7
        40  => x"1C40", -- LW r6, r1, 0
        41  => x"4E01", -- LI r7, 1
        42  => x"5BC4", -- BEQ r5, r7, DO_ADD
        43  => x"4E02", -- LI r7, 2
        44  => x"5BC4", -- BEQ r5, r7, DO_SUB
        45  => x"71D8", -- JAL r0, INPUT_LOOP

        -- DO_ADD
        46  => x"0798", -- ADD r3, r6, r3
        47  => x"700C", -- JAL r0, SHOW_RES

        -- DO_SUB
        48  => x"0F9D", -- SLT r7, r6, r3
        49  => x"5E09", -- BEQ r7, r0, NO_NEG
        50  => x"06F1", -- SUB r3, r3, r6
        51  => x"2640", -- SW r3, r1, 0
        52  => x"48C0", -- LI r4, 192
        53  => x"7433", -- JAL r2, LCD_CMD
        54  => x"482D", -- LI r4, 45
        55  => x"743B", -- JAL r2, LCD_CHAR
        56  => x"1640", -- LW r3, r1, 0
        57  => x"7006", -- JAL r0, FMT_RES

        -- NO_NEG
        58  => x"0799", -- SUB r3, r6, r3

        -- SHOW_RES
        59  => x"2640", -- SW r3, r1, 0
        60  => x"48C0", -- LI r4, 192
        61  => x"742B", -- JAL r2, LCD_CMD
        62  => x"1640", -- LW r3, r1, 0

        -- FMT_RES
        63  => x"7402", -- JAL r2, PRT_DEC
        64  => x"7000", -- JAL r0, 0

        -- PRT_DEC
        65  => x"2440", -- SW r2, r1, 0
        66  => x"4C01", -- LI r6, 1
        67  => x"0271", -- SUB r1, r1, r6
        68  => x"4CFF", -- LI r6, 255
        69  => x"2C40", -- SW r6, r1, 0
        70  => x"4C01", -- LI r6, 1
        71  => x"0271", -- SUB r1, r1, r6

        72  => x"4800", -- LI r4, 0
        73  => x"4A0A", -- LI r5, 10
        74  => x"0CED", -- SLT r6, r3, r5
        75  => x"6C05", -- BNE r6, r0, div_end
        76  => x"06E9", -- SUB r3, r3, r5
        77  => x"4C01", -- LI r6, 1
        78  => x"0930", -- ADD r4, r4, r6
        79  => x"71FB", -- JAL r0, div_loop

        80  => x"2640", -- SW r3, r1, 0
        81  => x"4C01", -- LI r6, 1
        82  => x"0271", -- SUB r1, r1, r6
        83  => x"0700", -- ADD r3, r4, r0
        84  => x"6634", -- BNE r3, r0, ext_lp

        85  => x"4C01", -- LI r6, 1
        86  => x"0270", -- ADD r1, r1, r6
        87  => x"1840", -- LW r4, r1, 0
        88  => x"4CFF", -- LI r6, 255
        89  => x"5985", -- BEQ r4, r6, prt_end
        90  => x"4C30", -- LI r6, 48
        91  => x"0930", -- ADD r4, r4, r6
        92  => x"7416", -- JAL r2, LCD_CHAR
        93  => x"71F8", -- JAL r0, prt_loop

        94  => x"4C01", -- LI r6, 1
        95  => x"0270", -- ADD r1, r1, r6
        96  => x"1440", -- LW r2, r1, 0
        97  => x"8080", -- JALR r0, r2, 0

        -- WAIT_LCD
        98  => x"4EF4", -- LI r7, 244
        99  => x"1DC0", -- w_loop: LW r6, r7, 0 
        100 => x"4A01", -- LI r5, 1
        101 => x"0DAA", -- AND r6, r6, r5  <--- ¡AQUÍ ESTABA EL MALDITO ERROR!
        102 => x"6C3D", -- BNE r6, r0, w_loop
        103 => x"8080", -- JALR r0, r2, 0

        -- LCD_CMD
        104 => x"2440", -- SW r2, r1, 0
        105 => x"4C01", -- LI r6, 1
        106 => x"0271", -- SUB r1, r1, r6
        107 => x"75F7", -- JAL r2, WAIT_LCD
        108 => x"4EF3", -- LI r7, 243
        109 => x"29C0", -- SW r4, r7, 0
        110 => x"4C01", -- LI r6, 1
        111 => x"0270", -- ADD r1, r1, r6
        112 => x"1440", -- LW r2, r1, 0
        113 => x"8080", -- JALR r0, r2, 0

        -- LCD_CHAR
        114 => x"2440", -- SW r2, r1, 0
        115 => x"4C01", -- LI r6, 1
        116 => x"0271", -- SUB r1, r1, r6
        117 => x"75ED", -- JAL r2, WAIT_LCD
        118 => x"4EF2", -- LI r7, 242
        119 => x"29C0", -- SW r4, r7, 0
        120 => x"4C01", -- LI r6, 1
        121 => x"0270", -- ADD r1, r1, r6
        122 => x"1440", -- LW r2, r1, 0
        123 => x"8080", -- JALR r0, r2, 0

        -- READ_KEYPAD
        124 => x"4EE2", -- LI r7, 226
        125 => x"1DC0", -- r_press: LW r6, r7, 0
        126 => x"4A10", -- LI r5, 16
        127 => x"09AA", -- AND r4, r6, r5
        128 => x"583D", -- BEQ r4, r0, r_press
        129 => x"4A0F", -- LI r5, 15
        130 => x"09AA", -- AND r4, r6, r5
        131 => x"1DC0", -- r_rel: LW r6, r7, 0
        132 => x"4A10", -- LI r5, 16
        133 => x"0DAA", -- AND r6, r6, r5
        134 => x"6C3D", -- BNE r6, r0, r_rel
        135 => x"8080", -- JALR r0, r2, 0

        others => x"0000"
    );
begin

    instruction_out <= rom_memory(to_integer(unsigned(instruction_addr)));


end DataFlow;
