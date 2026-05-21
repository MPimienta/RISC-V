# ==============================================================================
# 1. SETUP DE CONSTANTES Y PUNTEROS
# ==============================================================================
    LI r3, -16
    LI r6, -32
    LI r4, 0
    LI r7, 16

# ==============================================================================
# 2. SECUENCIA DE ENERGÍA PANTALLA OLED
# ==============================================================================
    LI r2, 8
    SW r2, 2(r3)
    LI r2, 10
    SW r2, 2(r3)
    LI r2, 26
    SW r2, 2(r3)

# ==============================================================================
# 3. INICIALIZACIÓN AVANZADA
# ==============================================================================
# ==============================================================================
# 3. INICIALIZACIÓN AVANZADA
# ==============================================================================
    LI r2, 174            # 0xAE: Display OFF
    JAL r1, SPI_SEND
    LI r2, 213            # 0xD5: Clock Divide
    JAL r1, SPI_SEND
    LI r2, 128            # 0x80: Ratio
    JAL r1, SPI_SEND
    LI r2, 168            # 0xA8: Multiplex
    JAL r1, SPI_SEND
    LI r2, 31             # 0x1F: 31 (Para 128x32)
    JAL r1, SPI_SEND
    LI r2, 32             # 0x20: Memory Mode
    JAL r1, SPI_SEND
    LI r2, 0              # 0x00: Horizontal
    JAL r1, SPI_SEND
    LI r2, 141            # 0x8D: Charge Pump
    JAL r1, SPI_SEND
    LI r2, 20             # 0x14: Enable
    JAL r1, SPI_SEND
    LI r2, 161            # 0xA1: Segment Remap (Rotación)
    JAL r1, SPI_SEND
    LI r2, 200            # 0xC8: COM Scan (Rotación)
    JAL r1, SPI_SEND
    
    # --- ¡NUEVO! CONFIGURACIÓN DE PINES HARDWARE (Deshacer el aplastamiento) ---
    LI r2, 218            # 0xDA: Set COM Pins Hardware Configuration
    JAL r1, SPI_SEND
    LI r2, 2              # 0x02: Secuencial (Obligatorio para pantallas 128x32)
    JAL r1, SPI_SEND
    # --------------------------------------------------------------------------

    LI r2, 33             # 0x21: Límites de Columna
    JAL r1, SPI_SEND
    LI r2, 0              # Inicio: Columna 0
    JAL r1, SPI_SEND
    LI r2, 127            # Fin: Columna 127
    JAL r1, SPI_SEND

    LI r2, 34             # 0x22: Límites de Página
    JAL r1, SPI_SEND
    LI r2, 0              # Inicio: Página 0
    JAL r1, SPI_SEND
    LI r2, 3              # Fin: Página 3 (Límite físico visible)
    JAL r1, SPI_SEND

    LI r2, 175            # 0xAF: Display ON
    JAL r1, SPI_SEND

# ==============================================================================
# 4. LIMPIAR PANTALLA
# Al escribir 512 ceros, chocará con el límite que acabamos de poner
# y el cursor de la pantalla volverá mágicamente a la posición 0,0.
# ==============================================================================
    LI r2, 27             # Modo Dato (DC=1)
    SW r2, 2(r3)

    LI r5, 4              # 4 Páginas
CLEAR_PAGES:
    LI r4, 128            # 128 Columnas
CLEAR_COLS:
    LI r2, 0
    JAL r1, SPI_SEND
    ADDI r4, r4, -1
    BNE r4, r0, CLEAR_COLS
    ADDI r5, r5, -1
    BNE r5, r0, CLEAR_PAGES

    LI r4, 0              # Restaurar r4 a 0 para usarlo en la RAM

    JAL r0, WAIT_PRESS    # Todo listo, a leer botones.

# ==============================================================================
# SUBRUTINA: ENVIAR POR SPI Y ESPERAR
# ==============================================================================
SPI_SEND:
    SW r2, 3(r3)
SPI_WAIT:
    LW r2, 4(r3)
    BNE r2, r0, SPI_WAIT
    JALR r0, r1, 0

# ==============================================================================
# BUCLE PRINCIPAL: ESPERAR PULSACIÓN
# ==============================================================================
WAIT_PRESS:
    LW r5, 2(r6)
    SLT r2, r5, r7
    BNE r2, r0, WAIT_PRESS
    SW r5, 0(r4)

# ==============================================================================
# DECODIFICADOR COMPLETO (0 a F)
# ==============================================================================
CHECK_0:
    LI r2, 16
    BNE r5, r2, CHECK_1
    JAL r0, DRAW_0
CHECK_1:
    LI r2, 17
    BNE r5, r2, CHECK_2
    JAL r0, DRAW_1
CHECK_2:
    LI r2, 18
    BNE r5, r2, CHECK_3
    JAL r0, DRAW_2
CHECK_3:
    LI r2, 19
    BNE r5, r2, CHECK_4
    JAL r0, DRAW_3
CHECK_4:
    LI r2, 20
    BNE r5, r2, CHECK_5
    JAL r0, DRAW_4
CHECK_5:
    LI r2, 21
    BNE r5, r2, CHECK_6
    JAL r0, DRAW_5
CHECK_6:
    LI r2, 22
    BNE r5, r2, CHECK_7
    JAL r0, DRAW_6
CHECK_7:
    LI r2, 23
    BNE r5, r2, CHECK_8
    JAL r0, DRAW_7
CHECK_8:
    LI r2, 24
    BNE r5, r2, CHECK_9
    JAL r0, DRAW_8
CHECK_9:
    LI r2, 25
    BNE r5, r2, CHECK_A
    JAL r0, DRAW_9
CHECK_A:
    LI r2, 26
    BNE r5, r2, CHECK_B
    JAL r0, DRAW_A
CHECK_B:
    LI r2, 27
    BNE r5, r2, CHECK_C
    JAL r0, DRAW_B
CHECK_C:
    LI r2, 28
    BNE r5, r2, CHECK_D
    JAL r0, DRAW_C
CHECK_D:
    LI r2, 29
    BNE r5, r2, CHECK_E
    JAL r0, DRAW_D
CHECK_E:
    LI r2, 30
    BNE r5, r2, CHECK_F
    JAL r0, DRAW_E
CHECK_F:
    LI r2, 31
    BNE r5, r2, WAIT_RELEASE
    JAL r0, DRAW_F

# ==============================================================================
# BUCLE: ESPERAR A QUE SUELTE LA TECLA
# ==============================================================================
WAIT_RELEASE:
    LW r5, 2(r6)
    SLT r2, r5, r7
    BEQ r2, r0, WAIT_RELEASE
    JAL r0, WAIT_PRESS

# ==============================================================================
# RUTINAS DE DIBUJO
# ==============================================================================
DRAW_0:
    LI r2, 62
    JAL r1, SPI_SEND
    LI r2, 81
    JAL r1, SPI_SEND
    LI r2, 73
    JAL r1, SPI_SEND
    LI r2, 69
    JAL r1, SPI_SEND
    LI r2, 62
    JAL r1, SPI_SEND
    JAL r0, WAIT_RELEASE
DRAW_1:
    LI r2, 0
    JAL r1, SPI_SEND
    LI r2, 66
    JAL r1, SPI_SEND
    LI r2, 127
    JAL r1, SPI_SEND
    LI r2, 64
    JAL r1, SPI_SEND
    LI r2, 0
    JAL r1, SPI_SEND
    JAL r0, WAIT_RELEASE
DRAW_2:
    LI r2, 66
    JAL r1, SPI_SEND
    LI r2, 97
    JAL r1, SPI_SEND
    LI r2, 81
    JAL r1, SPI_SEND
    LI r2, 73
    JAL r1, SPI_SEND
    LI r2, 70
    JAL r1, SPI_SEND
    JAL r0, WAIT_RELEASE
DRAW_3:
    LI r2, 33
    JAL r1, SPI_SEND
    LI r2, 65
    JAL r1, SPI_SEND
    LI r2, 69
    JAL r1, SPI_SEND
    LI r2, 75
    JAL r1, SPI_SEND
    LI r2, 49
    JAL r1, SPI_SEND
    JAL r0, WAIT_RELEASE
DRAW_4:
    LI r2, 24
    JAL r1, SPI_SEND
    LI r2, 20
    JAL r1, SPI_SEND
    LI r2, 18
    JAL r1, SPI_SEND
    LI r2, 127
    JAL r1, SPI_SEND
    LI r2, 16
    JAL r1, SPI_SEND
    JAL r0, WAIT_RELEASE
DRAW_5:
    LI r2, 39
    JAL r1, SPI_SEND
    LI r2, 69
    JAL r1, SPI_SEND
    LI r2, 69
    JAL r1, SPI_SEND
    LI r2, 69
    JAL r1, SPI_SEND
    LI r2, 57
    JAL r1, SPI_SEND
    JAL r0, WAIT_RELEASE
DRAW_6:
    LI r2, 60
    JAL r1, SPI_SEND
    LI r2, 74
    JAL r1, SPI_SEND
    LI r2, 73
    JAL r1, SPI_SEND
    LI r2, 73
    JAL r1, SPI_SEND
    LI r2, 48
    JAL r1, SPI_SEND
    JAL r0, WAIT_RELEASE
DRAW_7:
    LI r2, 1
    JAL r1, SPI_SEND
    LI r2, 113
    JAL r1, SPI_SEND
    LI r2, 9
    JAL r1, SPI_SEND
    LI r2, 5
    JAL r1, SPI_SEND
    LI r2, 3
    JAL r1, SPI_SEND
    JAL r0, WAIT_RELEASE
DRAW_8:
    LI r2, 54
    JAL r1, SPI_SEND
    LI r2, 73
    JAL r1, SPI_SEND
    LI r2, 73
    JAL r1, SPI_SEND
    LI r2, 73
    JAL r1, SPI_SEND
    LI r2, 54
    JAL r1, SPI_SEND
    JAL r0, WAIT_RELEASE
DRAW_9:
    LI r2, 6
    JAL r1, SPI_SEND
    LI r2, 73
    JAL r1, SPI_SEND
    LI r2, 73
    JAL r1, SPI_SEND
    LI r2, 41
    JAL r1, SPI_SEND
    LI r2, 30
    JAL r1, SPI_SEND
    JAL r0, WAIT_RELEASE
DRAW_A:
    LI r2, 126
    JAL r1, SPI_SEND
    LI r2, 17
    JAL r1, SPI_SEND
    LI r2, 17
    JAL r1, SPI_SEND
    LI r2, 17
    JAL r1, SPI_SEND
    LI r2, 126
    JAL r1, SPI_SEND
    JAL r0, WAIT_RELEASE
DRAW_B:
    LI r2, 127
    JAL r1, SPI_SEND
    LI r2, 73
    JAL r1, SPI_SEND
    LI r2, 73
    JAL r1, SPI_SEND
    LI r2, 73
    JAL r1, SPI_SEND
    LI r2, 54
    JAL r1, SPI_SEND
    JAL r0, WAIT_RELEASE
DRAW_C:
    LI r2, 62
    JAL r1, SPI_SEND
    LI r2, 65
    JAL r1, SPI_SEND
    LI r2, 65
    JAL r1, SPI_SEND
    LI r2, 65
    JAL r1, SPI_SEND
    LI r2, 34
    JAL r1, SPI_SEND
    JAL r0, WAIT_RELEASE
DRAW_D:
    LI r2, 127
    JAL r1, SPI_SEND
    LI r2, 65
    JAL r1, SPI_SEND
    LI r2, 65
    JAL r1, SPI_SEND
    LI r2, 34
    JAL r1, SPI_SEND
    LI r2, 28
    JAL r1, SPI_SEND
    JAL r0, WAIT_RELEASE
DRAW_E:
    LI r2, 127
    JAL r1, SPI_SEND
    LI r2, 73
    JAL r1, SPI_SEND
    LI r2, 73
    JAL r1, SPI_SEND
    LI r2, 73
    JAL r1, SPI_SEND
    LI r2, 65
    JAL r1, SPI_SEND
    JAL r0, WAIT_RELEASE
DRAW_F:
    LI r2, 127
    JAL r1, SPI_SEND
    LI r2, 9
    JAL r1, SPI_SEND
    LI r2, 9
    JAL r1, SPI_SEND
    LI r2, 9
    JAL r1, SPI_SEND
    LI r2, 1
    JAL r1, SPI_SEND
    JAL r0, WAIT_RELEASE
