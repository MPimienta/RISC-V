# ==========================================
# 1. INICIALIZACIÓN
# ==========================================
LI r1, 15          # r1 = 15  (0x000F)
LI r2, 3           # r2 =  3  (0x0003)

# ==========================================
# 2. RIESGOS DISTANCIA 1 (EX-EX Forwarding)
# ==========================================
# La instrucción SUB necesita a r3 inmediatamente, pero ADD aún no lo ha guardado.
ADD r3, r1, r2     # r3 = 15 + 3 = 18 (0x0012)
SUB r4, r3, r2     # r4 = 18 - 3 = 15 (0x000F) -> Requiere forward_a = "10"

# ==========================================
# 3. RIESGOS DISTANCIA 2 (MEM-EX Forwarding)
# ==========================================
# OR necesita r5, pero AND está en la etapa WB.
AND r5, r4, r1     # r5 = 15 & 15 = 15 (0x000F)
NOP                # Dejamos que AND avance una etapa más
OR  r6, r5, r2     # r6 = 15 | 3 = 15  (0x000F) -> Requiere forward_a = "01"

# ==========================================
# 4. RIESGO LOAD-USE (Burbuja / Stall + Forwarding)
# ==========================================
LI r7, 50          # Puntero de memoria RAM (Dirección 50)
SW r6, r7, 0       # RAM[50] = 15
LW r1, r7, 0       # r1 carga el 15. El dato real se obtiene en la etapa MEM.
XOR r2, r1, r4     # ¡Peligro! Uso en la etapa inmediata. r2 = 15 ^ 15 = 0.
                   # Tu Hazard Detection Unit debe congelar el PC un ciclo e insertar un NOP.

# ==========================================
# 5. TEST: ARITMÉTICA INMEDIATA Y DESPLAZAMIENTOS
# ==========================================
ADDI r1, r2, 1     # r1 = 0 + 1 = 1
SLL  r3, r1, r1    # r3 = 1 << 1 = 2 
SLT  r4, r1, r3    # r4 = (1 < 2) ? 1 : 0  -> r4 = 1

# ==========================================
# 6. TEST DE CONTROL: SALTOS (BNE y JALR)
# ==========================================
BNE r4, r2, salto  # Compara r4(1) con r2(0). 1 != 0, así que SALTA.
NOP                # Si tu procesador vacía el pipeline en saltos (flush), esto se ignora.

# Instrucción trampa: Si el salto falla, r1 se llenará de basura (999).
# Como 999 no cabe en 9 bits, lo construimos en 4 pasos matemáticos:
LI r1, 124         # Paso 1: Cargar 124 (cabe en 9 bits)
LI r5, 3           # Paso 2: Cargar 3 en r5 para usarlo como límite de desplazamiento
SLL r1, r1, r5     # Paso 3: 124 desplazado 3 bits a la izquierda (124 * 8 = 992)
ADDI r1, r1, 7     # Paso 4: Sumar 7 al resultado anterior (992 + 7 = 999)

salto:
LI r5, 20          # Cargamos la dirección 20 (u otra dir. base de tu RAM de instrucciones)
JALR r0, r5, 0     # Salta incondicionalmente a la dirección apuntada por r5.
                   # Usamos r0 como destino porque no nos importa guardar el retorno.