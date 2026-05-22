library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hazard_unit is
    Port ( 
        rs1_addr_id     : in std_logic_vector (2 downto 0);
        rs2_addr_id     : in std_logic_vector (2 downto 0);
        rd_addr_ex      : in std_logic_vector (2 downto 0);
        mem_to_reg_ex   : in std_logic; 
        branch_taken    : in std_logic; 
        pc_en           : out std_logic; 
        if_id_en        : out std_logic; 
        if_id_flush     : out std_logic; 
        id_ex_flush     : out std_logic  
    );
end hazard_unit;

architecture Behavioral of hazard_unit is
begin
    process(rs1_addr_id, rs2_addr_id, rd_addr_ex, mem_to_reg_ex, branch_taken)
    begin
        pc_en       <= '1';
        if_id_en    <= '1';
        if_id_flush <= '0';
        id_ex_flush <= '0';
        if (branch_taken = '1') then
            if_id_flush <= '1';
            id_ex_flush <= '1';
            
        elsif (mem_to_reg_ex = '1' and (rd_addr_ex = rs1_addr_id or rd_addr_ex = rs2_addr_id)) then
            pc_en       <= '0';
            if_id_en    <= '0';
            id_ex_flush <= '1';
        end if;
    end process;
end Behavioral;