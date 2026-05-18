# ==============================================================================
# 1. SETUP DE CONSTANTES Y PUNTEROS
# ==============================================================================
    LI r3, -16            # r3 = Base OLED (0xFFF0)
    LI r6, -32            # r6 = Base Keypad (0xFFE0)
    LI r4, 0              # r4 = Puntero RAM (Dirección 0)
    LI r7, 16             # r7 = Máscara para bit key_valid (0x0010)

# ==============================================================================
# 2. SECUENCIA DE ENERGÍA PANTALLA OLED (SSD1306)
# ==============================================================================
# Escribimos en el registro de Control (0xFFF2). 
# Bits: 4=VBAT, 3=VDD, 2=CS(0=Activo), 1=RES(0=Reset), 0=DC(0=Comando)

    LI r2, 8              # 01000b: VDD=1, CS=0, RES=0, DC=0
    SW r2, 2(r3)
    
    LI r2, 10             # 01010b: VDD=1, CS=0, RES=1, DC=0 (Quita el reset)
    SW r2, 2(r3)
    
    LI r2, 26             # 11010b: VBAT=1, VDD=1, CS=0, RES=1, DC=0
    SW r2, 2(r3)

# ==============================================================================
# 3. ENVIAR COMANDOS DE INICIALIZACIÓN (Usando Subrutina)
# ==============================================================================
    LI r2, 174            # Comando 0xAE: Display OFF
    JAL r1, SPI_SEND

    LI r2, 141            # Comando 0x8D: Charge Pump
    JAL r1, SPI_SEND
    LI r2, 20             # Valor 0x14: Enable
    JAL r1, SPI_SEND

    LI r2, 32             # Comando 0x20: Memory Mode
    JAL r1, SPI_SEND
    LI r2, 0              # Valor 0x00: Modo Horizontal
    JAL r1, SPI_SEND

    LI r2, 175            # Comando 0xAF: Display ON
    JAL r1, SPI_SEND

# ==============================================================================
# 4. PASAR A MODO DATO Y ARRANCAR PROGRAMA
# ==============================================================================
    LI r2, 27             # 11011b: VBAT=1, VDD=1, CS=0, RES=1, DC=1 (Modo Dato)
    SW r2, 2(r3)
    JAL r0, WAIT_PRESS    # Salta al bucle principal

# ==============================================================================
# SUBRUTINA: ENVIAR POR SPI Y ESPERAR (Reutilizable)
# ==============================================================================
SPI_SEND:
    SW r2, 3(r3)          # Envia el valor de r2 por SPI Data (0xFFF3)
SPI_WAIT:
    LW r2, 4(r3)          # Lee OLED Status (0xFFF4)
    BNE r2, r0, SPI_WAIT  # Bucle si status != 0 (OLED Busy)
    JALR r0, r1, 0        # Retorna a la instrucción guardada en r1 (ra)

# ==============================================================================
# 5. BUCLE PRINCIPAL: ESPERAR PULSACIÓN
# ==============================================================================
WAIT_PRESS:
    LW r5, 2(r6)          # Lee el teclado (0xFFE2)
    SLT r2, r5, r7        # Si r5 < 16 (soltado), r2 = 1. Si r5 >= 16, r2 = 0.
    BNE r2, r0, WAIT_PRESS# Si r2 != 0 (tecla soltada), sigue esperando

    SW r5, 0(r4)          # Guardamos el valor leído en RAM[0]

# ==============================================================================
# 6. DECODIFICADOR (SWITCH-CASE)
# ==============================================================================
CHECK_1:
    LI r2, 17             # 0x11 (Valor del '1')
    BNE r5, r2, CHECK_2   # Si r5 != '1', pasa a comprobar el '2'
    JAL r0, DRAW_1        # Si es '1', salta a dibujar

CHECK_2:
    LI r2, 18             # 0x12 (Valor del '2')
    BNE r5, r2, WAIT_RELEASE # Si r5 != '2', ignoramos y esperamos
    JAL r0, DRAW_2        # Si es '2', salta a dibujar

# ==============================================================================
# 7. BUCLE: ESPERAR A QUE EL DEDO SUELTE LA TECLA
# ==============================================================================
WAIT_RELEASE:
    LW r5, 2(r6)          # Lee el teclado
    SLT r2, r5, r7        # r2 = 1 si soltado (r5 < 16), r2 = 0 si pulsado
    BEQ r2, r0, WAIT_RELEASE # Si r2 == 0 (sigue pulsado), sigue esperando
    JAL r0, WAIT_PRESS    # Si soltado, vuelve al inicio a por otra tecla

# ==============================================================================
# 8. RUTINAS DE DIBUJO (OLED) - ¡Súper compactas gracias a la subrutina!
# ==============================================================================
DRAW_1:
    LI r2, 0              # Columna 1
    JAL r1, SPI_SEND
    LI r2, 66             # Columna 2
    JAL r1, SPI_SEND
    LI r2, 127            # Columna 3
    JAL r1, SPI_SEND
    LI r2, 64             # Columna 4
    JAL r1, SPI_SEND
    LI r2, 0              # Columna 5
    JAL r1, SPI_SEND
    JAL r0, WAIT_RELEASE  # Termina de dibujar y va a esperar

DRAW_2:
    LI r2, 66             # Columna 1
    JAL r1, SPI_SEND
    LI r2, 97             # Columna 2
    JAL r1, SPI_SEND
    LI r2, 81             # Columna 3
    JAL r1, SPI_SEND
    LI r2, 73             # Columna 4
    JAL r1, SPI_SEND
    LI r2, 70             # Columna 5
    JAL r1, SPI_SEND
    JAL r0, WAIT_RELEASE  # Termina de dibujar y va a esperar