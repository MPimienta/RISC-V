----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/09/2026 05:15:30 PM
-- Design Name: 
-- Module Name: id_ex_register - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity id_ex_register is
    Port ( 
        clk     : in std_logic ;
        reset   : in std_logic ;
        flush   : in std_logic ;
        en      : in std_logic ;
        
        pc_in       : in std_logic_vector (15 downto 0);
        rs1_data_in : in std_logic_vector (15 downto 0);
        rs2_data_in : in std_logic_vector (15 downto 0);
        imm_in      : in std_logic_vector (15 downto 0);
        rs1_addr_in : in std_logic_vector (2 downto 0);
        rs2_addr_in : in std_logic_vector (2 downto 0);
        rd_addr_in  : in std_logic_vector (2 downto 0);
        
        ctrl_alu_sel_in     : in std_logic_vector (2 downto 0);
        ctrl_alu_src_b_in   : in std_logic;
        ctrl_mem_write_in   : in std_logic;
        ctrl_reg_write_in   : in std_logic;
        ctrl_mem_to_reg_in  : in std_logic;
        
        pc_out           : out std_logic_vector (15 downto 0);
        rs1_data_out     : out std_logic_vector (15 downto 0);
        rs2_data_out     : out std_logic_vector (15 downto 0);
        imm_out          : out std_logic_vector (15 downto 0);
        rs1_addr_out     : out std_logic_vector (2 downto 0);
        rs2_addr_out     : out std_logic_vector (2 downto 0);
        rd_addr_out      : out std_logic_vector (2 downto 0);
        
        ctrl_alu_sel_out    : out std_logic_vector (2 downto 0);
        ctrl_alu_src_b_out  : out std_logic;
        ctrl_mem_write_out  : out std_logic;
        ctrl_reg_write_out  : out std_logic;
        ctrl_mem_to_reg_out : out std_logic
        
        
    );
end id_ex_register;

architecture Behavioral of id_ex_register is
begin
    process(clk, reset)
    begin
        if (reset = '1') then
            pc_out <= (others => '0');
            rs1_data_out <= (others => '0');
            rs2_data_out <= (others => '0');
            imm_out <= (others => '0');
            rs1_addr_out <= (others => '0');
            rs2_addr_out <= (others => '0');
            rd_addr_out <= (others => '0');
            
            ctrl_alu_sel_out <= (others => '0');
            ctrl_alu_src_b_out <= '0';
            ctrl_mem_write_out <= '0';
            ctrl_reg_write_out <= '0';
            ctrl_mem_to_reg_out <= '0';
            
        elsif rising_edge(clk) then
            if (flush = '1') then
                pc_out <= (others => '0');
                rs1_data_out <= (others => '0');
                rs2_data_out <= (others => '0');
                imm_out <= (others => '0');
                rs1_addr_out <= (others => '0');
                rs2_addr_out <= (others => '0');
                rd_addr_out <= (others => '0');
                
                ctrl_alu_sel_out <= (others => '0');
                ctrl_alu_src_b_out <= '0';
                ctrl_mem_write_out <= '0';
                ctrl_reg_write_out <= '0';
                ctrl_mem_to_reg_out <= '0';

            elsif (en = '1') then
                pc_out <= pc_in;
                rs1_data_out <= rs1_data_in;
                rs2_data_out <= rs2_data_in;
                imm_out <= imm_in;
                rs1_addr_out <= rs1_addr_in;
                rs2_addr_out <= rs2_addr_in;
                rd_addr_out <= rd_addr_in;
                
                ctrl_alu_sel_out <= ctrl_alu_sel_in;
                ctrl_alu_src_b_out <= ctrl_alu_src_b_in;
                ctrl_mem_write_out <= ctrl_mem_write_in;
                ctrl_reg_write_out <= ctrl_reg_write_in;
                ctrl_mem_to_reg_out <= ctrl_mem_to_reg_in;
            end if;
        end if;
    end process;
end Behavioral;
