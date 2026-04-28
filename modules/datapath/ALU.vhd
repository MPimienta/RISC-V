library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port ( 
            A       :   in  std_logic_vector (7 downto 0); -- Acumulador 
            B       :   in  std_logic_vector (7 downto 0); -- Valor de memoria / inmediato
            ALU_Sel :   in  std_logic_vector (1 downto 0); -- Código de Selección de instrucción
            Result  :   out std_logic_vector (7 downto 0);
            Zero    :   out std_logic -- Flag útil para BEQ, se activa cuando Result = 0
            );
end ALU;

architecture DataFlow of ALU is

signal res_internal : std_logic_vector (7 downto 0);

begin

    with ALU_Sel select
        res_internal <= 
            std_logic_vector (unsigned(A) + unsigned(B)) when "000",
            std_logic_vector (unsigned(A) - unsigned(B)) when "001",
            (A AND B) when "010",
            (A OR B) when "011";
            
    result <= res_internal;
    
    Zero <= '1' when (res_internal = "00000000") else '0';

end DataFlow;