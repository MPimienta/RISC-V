LI R1, 1
    LI R3, -16
    LI R6, -32
    LI R4, 0
    LI R7, 16

    LI R2, 27
    SW R2, 2(R3)

WAIT_PRESS:
    LW R5, 2(R6)
    SLT R2, R5, R7
    BNE R2, R0, WAIT_PRESS

    SW R5, 0(R4)

CHECK_1:
    LI R2, 17
    BNE R5, R2, CHECK_2
    JAL DRAW_1

CHECK_2:
    LI R2, 18
    BNE R5, R2, WAIT_RELEASE
    JAL DRAW_2

WAIT_RELEASE:
    LW R5, 2(R6)
    SLT R2, R5, R7
    BEQ R2, R0, WAIT_RELEASE
    JAL WAIT_PRESS

DRAW_1:
    OLED_WAIT_1_1:
        LW R2, 4(R3)
        BNE R2, R0, OLED_WAIT_1_1
    LI R2, 0
    SW R2, 3(R3)

    OLED_WAIT_1_2:
        LW R2, 4(R3)
        BNE R2, R0, OLED_WAIT_1_2
    LI R2, 66
    SW R2, 3(R3)

    OLED_WAIT_1_3:
        LW R2, 4(R3)
        BNE R2, R0, OLED_WAIT_1_3
    LI R2, 127
    SW R2, 3(R3)

    OLED_WAIT_1_4:
        LW R2, 4(R3)
        BNE R2, R0, OLED_WAIT_1_4
    LI R2, 64
    SW R2, 3(R3)

    OLED_WAIT_1_5:
        LW R2, 4(R3)
        BNE R2, R0, OLED_WAIT_1_5
    LI R2, 0
    SW R2, 3(R3)

    JAL WAIT_RELEASE

DRAW_2:
    OLED_WAIT_2_1:
        LW R2, 4(R3)
        BNE R2, R0, OLED_WAIT_2_1
    LI R2, 66
    SW R2, 3(R3)

    OLED_WAIT_2_2:
        LW R2, 4(R3)
        BNE R2, R0, OLED_WAIT_2_2
    LI R2, 97
    SW R2, 3(R3)

    OLED_WAIT_2_3:
        LW R2, 4(R3)
        BNE R2, R0, OLED_WAIT_2_3
    LI R2, 81
    SW R2, 3(R3)

    OLED_WAIT_2_4:
        LW R2, 4(R3)
        BNE R2, R0, OLED_WAIT_2_4
    LI R2, 73
    SW R2, 3(R3)

    OLED_WAIT_2_5:
        LW R2, 4(R3)
        BNE R2, R0, OLED_WAIT_2_5
    LI R2, 70
    SW R2, 3(R3)

    JAL WAIT_RELEASE