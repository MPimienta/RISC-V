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
        -- PREPARACIÓN Y ENCENDIDO
        -- ==========================================
        0  => x"4E01", -- LI r7, 1      (Constante 1 para restas)
        1  => x"481A", -- LI r4, 26     (0x1A: VDD=1, VBAT=1, CS=0, RES=1, D/C=0 Cmd)
        2  => x"2832", -- SW r4, r0, -14(Escribir en 0xFFF2 el Control)

        -- Bucle de Retardo (Dar tiempo a la OLED)
        3  => x"4202", -- LI r1, 2
        4  => x"4402", -- LI r2, 2
        --3  => x"42FF", -- LI r1, 255
        --4  => x"44FF", -- LI r2, 255
        5  => x"04B9", -- SUB r2, r2, r7
        6  => x"643F", -- BNE r2, r0, -1  (Si r2!=0, salta a SUB r2)
        7  => x"0279", -- SUB r1, r1, r7
        8  => x"623C", -- BNE r1, r0, -4  (Si r1!=0, salta a LI r2)

        -- ==========================================
        -- INICIALIZACIÓN DEL SSD1306 (Comandos)
        -- ==========================================
        -- Patrón de macro por cada byte:
        -- LI r4, BYTE (48XX) | SW r4, r0, -13 (2833) | LW r5, r0, -12 (1A34) | BNE r5, r0, -1 (6A3F)
        
        9  => x"48AE", 10 => x"2833", 11 => x"1A34", 12 => x"6A3F", -- 0xAE: Display OFF
        13 => x"48D5", 14 => x"2833", 15 => x"1A34", 16 => x"6A3F", -- 0xD5: Reloj
        17 => x"4880", 18 => x"2833", 19 => x"1A34", 20 => x"6A3F", -- 0x80: Ratio
        21 => x"48A8", 22 => x"2833", 23 => x"1A34", 24 => x"6A3F", -- 0xA8: Mux Ratio
        25 => x"481F", 26 => x"2833", 27 => x"1A34", 28 => x"6A3F", -- 0x1F: Para 128x32
        29 => x"4820", 30 => x"2833", 31 => x"1A34", 32 => x"6A3F", -- 0x20: Addressing Mode
        33 => x"4800", 34 => x"2833", 35 => x"1A34", 36 => x"6A3F", -- 0x00: Horizontal Auto-Inc
        37 => x"488D", 38 => x"2833", 39 => x"1A34", 40 => x"6A3F", -- 0x8D: Charge Pump
        41 => x"4814", 42 => x"2833", 43 => x"1A34", 44 => x"6A3F", -- 0x14: Enable Pump
        45 => x"48AF", 46 => x"2833", 47 => x"1A34", 48 => x"6A3F", -- 0xAF: Display ON

        -- ==========================================
        -- MODO DATOS Y LIMPIAR PANTALLA (CLEAR SCREEN)
        -- ==========================================
        49 => x"481B", -- LI r4, 27     (0x1B: Igual que antes pero D/C=1 Datos)
        50 => x"2832", -- SW r4, r0, -14
        
        -- Bucle de limpieza (Envia 0x00 512 veces)
        51 => x"4204", -- LI r1, 4      (Bucle Externo: 4 páginas)
        52 => x"4480", -- LI r2, 128    (Bucle Interno: 128 columnas)
        53 => x"4800", -- LI r4, 0      (Píxeles apagados)
        54 => x"2833", -- SW r4, r0, -13 (Enviar SPI)
        55 => x"1A34", -- LW r5, r0, -12 (Leer estado)
        56 => x"6A3F", -- BNE r5, r0, -1 (Esperar SPI)
        57 => x"04B9", -- SUB r2, r2, r7
        58 => x"643C", -- BNE r2, r0, -4 (Fin Bucle interno)
        59 => x"0279", -- SUB r1, r1, r7 
        60 => x"6238", -- BNE r1, r0, -8 (Fin Bucle externo)

        -- ==========================================
        -- RESETEAR CURSOR A 0,0 (Modo Comando)
        -- ==========================================
        61 => x"481A", 62 => x"2832", -- Set D/C = 0
        63 => x"4821", 64 => x"2833", 65 => x"1A34", 66 => x"6A3F", -- Column Addr Command
        67 => x"4800", 68 => x"2833", 69 => x"1A34", 70 => x"6A3F", -- Start 0
        71 => x"487F", 72 => x"2833", 73 => x"1A34", 74 => x"6A3F", -- End 127
        75 => x"4822", 76 => x"2833", 77 => x"1A34", 78 => x"6A3F", -- Page Addr Command
        79 => x"4800", 80 => x"2833", 81 => x"1A34", 82 => x"6A3F", -- Start 0
        83 => x"4803", 84 => x"2833", 85 => x"1A34", 86 => x"6A3F", -- End 3
        87 => x"481B", 88 => x"2832", -- Set D/C = 1 (Modo Datos)

        -- ==========================================
        -- ESCRIBIR TEXTO: "Hola" (Mapas de bits)
        -- ==========================================
        -- Letra 'H'
        89  => x"487F", 90  => x"2833", 91  => x"1A34", 92  => x"6A3F",
        93  => x"4808", 94  => x"2833", 95  => x"1A34", 96  => x"6A3F",
        97  => x"4808", 98  => x"2833", 99  => x"1A34", 100 => x"6A3F",
        101 => x"4808", 102 => x"2833", 103 => x"1A34", 104 => x"6A3F",
        105 => x"487F", 106 => x"2833", 107 => x"1A34", 108 => x"6A3F",
        109 => x"4800", 110 => x"2833", 111 => x"1A34", 112 => x"6A3F", -- Espaciado

        -- Letra 'o'
        113 => x"4838", 114 => x"2833", 115 => x"1A34", 116 => x"6A3F",
        117 => x"4844", 118 => x"2833", 119 => x"1A34", 120 => x"6A3F",
        121 => x"4844", 122 => x"2833", 123 => x"1A34", 124 => x"6A3F",
        125 => x"4844", 126 => x"2833", 127 => x"1A34", 128 => x"6A3F",
        129 => x"4820", 130 => x"2833", 131 => x"1A34", 132 => x"6A3F",
        133 => x"4800", 134 => x"2833", 135 => x"1A34", 136 => x"6A3F",

        -- Letra 'l'
        137 => x"4800", 138 => x"2833", 139 => x"1A34", 140 => x"6A3F",
        141 => x"4841", 142 => x"2833", 143 => x"1A34", 144 => x"6A3F",
        145 => x"487F", 146 => x"2833", 147 => x"1A34", 148 => x"6A3F",
        149 => x"4840", 150 => x"2833", 151 => x"1A34", 152 => x"6A3F",
        153 => x"4800", 154 => x"2833", 155 => x"1A34", 156 => x"6A3F",
        157 => x"4800", 158 => x"2833", 159 => x"1A34", 160 => x"6A3F",

        -- Letra 'a'
        161 => x"4820", 162 => x"2833", 163 => x"1A34", 164 => x"6A3F",
        165 => x"4854", 166 => x"2833", 167 => x"1A34", 168 => x"6A3F",
        169 => x"4854", 170 => x"2833", 171 => x"1A34", 172 => x"6A3F",
        173 => x"4854", 174 => x"2833", 175 => x"1A34", 176 => x"6A3F",
        177 => x"4878", 178 => x"2833", 179 => x"1A34", 180 => x"6A3F",
        181 => x"4800", 182 => x"2833", 183 => x"1A34", 184 => x"6A3F",

        -- ==========================================
        -- BUCLE INFINITO (FIN)
        -- ==========================================
        185 => x"7000", -- JAL r0, 0 (Se queda saltando a sí mismo)

        others => x"0000"
    );
begin

    instruction_out <= rom_memory(to_integer(unsigned(instruction_addr)));


end DataFlow;
