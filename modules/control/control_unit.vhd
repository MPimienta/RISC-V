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
        opcode : in std_logic_vector(3 downto 0);
        funct : in std_logic_vector(2 downto 0);
        zero : in std_logic;
        
        -- Señales para el Datapath
        pc_en : out std_logic;
        pc_load : out std_logic;
        reg_write : out std_logic;
        alu_sel : out std_logic_vector(2 downto 0);
        alu_src_b : out std_logic;
        mem_write  : out std_logic;
        mem_to_reg : out std_logic;
        ir_high_en : out std_logic;
        ir_low_en : out std_logic
    );
end control_unit;

architecture Behavioral of control_unit is
    type state_type is (ST_FETCH_HIGH, ST_FETCH_LOW, ST_DECODE, ST_EXECUTE, ST_JUMP, ST_MEM);
    signal current_state, next_state : state_type;
begin

    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= ST_FETCH_HIGH;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    process(current_state, opcode, zero, funct)
    begin
        -- Valores por defecto
        pc_en          <= '0';
        pc_load        <= '0';
        reg_write      <= '0';
        ir_high_en     <= '0';
        ir_low_en      <= '0';
        mem_write      <= '0';
        alu_src_b      <= '0'; 
        mem_to_reg     <= '0';
        alu_sel        <= "111"; 
        next_state     <= current_state;

        case current_state is
            when ST_FETCH_HIGH =>
                ir_high_en <= '1';
                pc_en <= '1';
                next_state <= ST_FETCH_LOW;
                
            when ST_FETCH_LOW =>
                ir_low_en <= '1'; 
                pc_en <= '1';
                next_state <= ST_DECODE;

            when ST_DECODE =>
                if opcode = "0101" or opcode = "0111" or opcode = "0110" or opcode = "1000" then -- BEQ || JAL || BNE || JALR
                    next_state <= ST_JUMP;
                elsif opcode = "0001" or opcode = "0010" then -- LW o SW
                    next_state <= ST_MEM;
                else
                    next_state <= ST_EXECUTE;
                end if;

            when ST_EXECUTE =>
                reg_write <= '1';
                alu_src_b <= '0'; 
                case opcode is
                    when "0000" =>
                        case funct is
                            when "000" => alu_sel <= "000"; -- ADD 
                            when "001" => alu_sel <= "001"; -- SUB
                            when "010" => alu_sel <= "010"; -- AND
                            when "011" => alu_sel <= "011"; -- OR
                            when "100" => alu_sel <= "100"; -- SLL
                            when "101" => alu_sel <= "101"; -- SLT
                            when "110" => alu_sel <= "110"; -- XOR
                            when others => alu_sel <= "111"; -- LI
                        end case;
                        
                    when "0011" => 
                        alu_sel <= "000";   -- Suma
                        alu_src_b <= '1';   -- Inmediato
                    
                    when "0100" => 
                        alu_sel <= "111";   -- Pasa B limpio 
                        alu_src_b <= '1';   -- Inmediato
                        
                    when others => 
                        alu_sel <= "111"; 
                end case;
                
                next_state <= ST_FETCH_HIGH;
                
            when ST_MEM =>
                alu_sel <= "000"; 
                alu_src_b <= '1';
                
                if opcode = "0010" then 
                    mem_write <= '1';  -- SW
                    next_state <= ST_FETCH_HIGH; 
                else                    
                    reg_write <= '1'; 
                    mem_to_reg <= '1';
                    next_state <= ST_FETCH_HIGH;
                end if;

            

            when ST_JUMP =>
                if opcode = "0101" then     -- BEQ
                    alu_sel <= "001";
                    alu_src_b <= '0';
                    if zero = '1' then 
                        pc_load <= '1';     
                        pc_en <= '1';
                    end if;
                    
                elsif opcode = "0110" then  -- BNE
                    alu_sel <= "001";
                    alu_src_b <= '0';
                    if zero = '0' then 
                        pc_load <= '1';
                        pc_en <= '1';
                    end if;
                    
                elsif opcode = "0111" then  -- JAL
                    pc_load <= '1';
                    pc_en <= '1';
                    
                elsif opcode = "1000" then  -- JALR
                    pc_load <= '1';
                    pc_en <= '1';
                end if;
                
                next_state <= ST_FETCH_HIGH;
        end case;
    end process;
end Behavioral;
