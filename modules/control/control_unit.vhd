----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/25/2026 09:48:35 PM
-- Design Name: 
-- Module Name: control_unit - Structural
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
use IEEE.NUMERIC_STD.ALL;

entity control_unit is
    Port (
        opcode      : in std_logic_vector(3 downto 0);
        funct       : in std_logic_vector(2 downto 0);
        alu_sel     : out std_logic_vector(2 downto 0);
        alu_src_b   : out std_logic;
        mem_write   : out std_logic;
        reg_write   : out std_logic;
        mem_to_reg  : out std_logic;
        branch_eq   : out std_logic;
        branch_neq  : out std_logic;
        jump_jal    : out std_logic;
        jump_jalr   : out std_logic
    );
end control_unit;

architecture Behavioral of control_unit is
begin

    process(opcode, funct)
    begin
        alu_sel     <= "111"; 
        alu_src_b   <= '0';
        mem_write   <= '0';
        reg_write   <= '0';
        mem_to_reg  <= '0';
        branch_eq   <= '0';
        branch_neq  <= '0';
        jump_jal    <= '0';
        jump_jalr   <= '0';

        case opcode is
            when "0000" => -- TIPO R (Aritmético/Lógico)
                reg_write <= '1';
                alu_src_b <= '0';
                case funct is
                    when "000" => alu_sel <= "000"; -- ADD 
                    when "001" => alu_sel <= "001"; -- SUB
                    when "010" => alu_sel <= "010"; -- AND
                    when "011" => alu_sel <= "011"; -- OR
                    when "100" => alu_sel <= "100"; -- SLL
                    when "101" => alu_sel <= "101"; -- SLT
                    when "110" => alu_sel <= "110"; -- XOR
                    when others => alu_sel <= "111"; -- NOP
                end case;
                
            when "0001" => -- LW
                reg_write <= '1';
                mem_to_reg <= '1';
                alu_src_b <= '1';
                alu_sel <= "000";
                
            when "0010" => -- SW
                mem_write <= '1';
                alu_src_b <= '1';
                alu_sel <= "000";
                
            when "0011" => -- ADDI / Inmediato
                reg_write <= '1';
                alu_src_b <= '1';
                alu_sel <= "000"; 
                
            when "0100" => -- LI
                reg_write <= '1';
                alu_src_b <= '1';
                alu_sel <= "111";
                
            when "0101" => -- BEQ
                branch_eq <= '1';
                alu_src_b <= '0';
                alu_sel <= "001";
                
            when "0110" => -- BNE
                branch_neq <= '1';
                alu_src_b <= '0';
                alu_sel <= "001";
                
            when "0111" => -- JAL
                jump_jal <= '1';
                reg_write <= '1';
                
            when "1000" => -- JALR
                jump_jalr <= '1';
                reg_write <= '1';
                
            when others =>
                null;
        end case;
    end process;

end Behavioral;
