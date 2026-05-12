library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hazard_unit is
    Port ( 
        -- Para el Load-Use Hazard (Miramos de ID a EX)
        rs1_addr_id     : in std_logic_vector (2 downto 0);
        rs2_addr_id     : in std_logic_vector (2 downto 0);
        rd_addr_ex      : in std_logic_vector (2 downto 0);
        mem_to_reg_ex   : in std_logic; -- Si está a '1', la instrucción en EX es un LW
        
        -- Para el Control Hazard (Saltos resueltos en EX)
        branch_taken    : in std_logic; 
        
        -- SALIDAS de control del flujo
        pc_en           : out std_logic; -- Para congelar el Program Counter
        if_id_en        : out std_logic; -- Para congelar el registro IF/ID
        if_id_flush     : out std_logic; -- Para vaciar IF/ID (Burbuja 1)
        id_ex_flush     : out std_logic  -- Para vaciar ID/EX (Burbuja 2)
    );
end hazard_unit;

architecture Behavioral of hazard_unit is
begin
    process(rs1_addr_id, rs2_addr_id, rd_addr_ex, mem_to_reg_ex, branch_taken)
    begin
        -- ESTADO NORMAL (Flujo continuo)
        pc_en       <= '1';
        if_id_en    <= '1';
        if_id_flush <= '0';
        id_ex_flush <= '0';

        -- 1. CONTROL HAZARD: ¿Se ha tomado un salto en la etapa EX?
        if (branch_taken = '1') then
            -- Vaciamos las dos instrucciones que entraron por error
            if_id_flush <= '1';
            id_ex_flush <= '1';
            -- Nota: No congelamos el PC, porque tiene que cargar la nueva dirección de salto.
            
        -- 2. LOAD-USE HAZARD: ¿La instrucción en EX es un LW y necesitamos su destino?
        elsif (mem_to_reg_ex = '1' and (rd_addr_ex = rs1_addr_id or rd_addr_ex = rs2_addr_id)) then
            -- ¡ATASCO! Congelamos el PC y el registro IF/ID
            pc_en       <= '0';
            if_id_en    <= '0';
            -- Vaciamos el registro ID/EX para meter una burbuja (NOP) en el tubo
            id_ex_flush <= '1';
        end if;
    end process;
end Behavioral;