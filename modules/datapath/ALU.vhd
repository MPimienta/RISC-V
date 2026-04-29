library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port ( 
            A       :   in  std_logic_vector (7 downto 0); -- Valor 
            B       :   in  std_logic_vector (7 downto 0); -- Valor de memoria / inmediato
            ALU_Sel :   in  std_logic_vector (2 downto 0); -- Código de Selección de instrucción
            Result  :   out std_logic_vector (7 downto 0);
            Zero    :   out std_logic -- Flag útil para BEQ, se activa cuando Result = 0
            );
end ALU;

architecture Dataflow of ALU is
    signal res_slt : std_logic_vector(7 downto 0);
    signal res_sll : std_logic_vector(7 downto 0);
    signal res_internal : std_logic_vector(7 downto 0);
begin

    -- Lógica para SLT (Set Less Than)
    res_slt <= "00000001" when (signed(A) < signed(B)) else "00000000";

    -- Lógica para SLL (Shift Left Logical)
    res_sll <= std_logic_vector(shift_left(unsigned(A), to_integer(unsigned(B(2 downto 0)))));

    res_internal <= 
        std_logic_vector(unsigned(A) + unsigned(B)) when ALU_Sel = "000" else
        std_logic_vector(unsigned(A) - unsigned(B)) when ALU_Sel = "001" else
        (A AND B)                                   when ALU_Sel = "010" else
        (A OR B)                                    when ALU_Sel = "011" else
        res_sll                                     when ALU_Sel = "100" else
        res_slt                                     when ALU_Sel = "101" else
        (A XOR B)                                   when ALU_Sel = "110" else
        B                                           when ALU_Sel = "111" else
        A;

    Result <= res_internal;
    Zero   <= '1' when (res_internal = "00000000") else '0';

end Dataflow;