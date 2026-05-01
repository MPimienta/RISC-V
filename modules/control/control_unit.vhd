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
        clk : in std_logic;
        reset : in std_logic;
        opcode : in std_logic_vector(7 downto 0);
        zero : in std_logic;
        
        -- Señales para el Datapath
        pc_en : out std_logic;
        pc_load : out std_logic;
        reg_write : out std_logic;
        alu_sel : out std_logic_vector(2 downto 0);
        ir_en : out std_logic
    );
end control_unit;

architecture Behavioral of control_unit is
    type state_type is (ST_FETCH, ST_DECODE, ST_EXECUTE, ST_WRITEBACK, ST_JUMP);
    signal current_state, next_state : state_type;
begin

    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= ST_FETCH;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    process(current_state, opcode, zero)
    begin
        -- Valores por defecto
        pc_en <= '0';
        pc_load <= '0';
        reg_write <= '0';
        ir_en <= '0';
        alu_sel <= "111";
        next_state <= ST_FETCH;

        case current_state is
            when ST_FETCH =>
                ir_en <= '1';
                pc_en <= '1';
                next_state <= ST_DECODE;

            when ST_DECODE =>
                if opcode = X"08" or opcode = X"09" then
                    next_state <= ST_JUMP;
                else
                    next_state <= ST_EXECUTE;
                end if;

            when ST_EXECUTE =>
                case opcode is
                    when X"01" => alu_sel <= "000"; -- ADD 
                    when X"02" => alu_sel <= "001"; -- SUB 
                    when X"03" => alu_sel <= "010"; -- AND 
                    when X"04" => alu_sel <= "011"; -- OR 
                    when X"05" => alu_sel <= "100"; -- SLL
                    when X"06" => alu_sel <= "101"; -- SLT
                    when X"07" => alu_sel <= "110"; -- XOR
                    when others => alu_sel <= "111"; -- B
                end case;
                next_state <= ST_WRITEBACK;

            when ST_WRITEBACK =>
                reg_write  <= '1';
                next_state <= ST_FETCH;

            when ST_JUMP =>
                -- BEQ
                if opcode = X"08" then 
                    alu_sel <= "001"; 
                    if zero = '1' then pc_load <= '1'; end if;
                -- JAL
                elsif opcode = X"09" then
                    pc_load <= '1';
                end if;
                next_state <= ST_FETCH;
        end case;
    end process;
end Behavioral;
