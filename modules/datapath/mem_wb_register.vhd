----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/09/2026 05:47:49 PM
-- Design Name: 
-- Module Name: mem_wb_register - Behavioral
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

entity mem_wb_register is
    Port ( 
        clk                 : in std_logic ;
        reset               : in std_logic ;
        
        alu_result_in       : in std_logic_vector (15 downto 0);
        ram_data_in         : in std_logic_vector (15 downto 0); 
        rd_addr_in          : in std_logic_vector (2 downto 0);
        
        ctrl_reg_write_in   : in std_logic;
        ctrl_mem_to_reg_in  : in std_logic;
        
        alu_result_out      : out std_logic_vector (15 downto 0);
        ram_data_out        : out std_logic_vector (15 downto 0);
        rd_addr_out         : out std_logic_vector (2 downto 0);
        
        ctrl_reg_write_out  : out std_logic;
        ctrl_mem_to_reg_out : out std_logic
    );
end mem_wb_register;

architecture Behavioral of mem_wb_register is
begin
    process(clk, reset)
    begin
        if (reset = '1') then
            alu_result_out <= (others => '0');
            ram_data_out <= (others => '0');
            rd_addr_out <= (others => '0');
            ctrl_reg_write_out <= '0';
            ctrl_mem_to_reg_out <= '0';
            
        elsif rising_edge(clk) then
            alu_result_out <= alu_result_in;
            ram_data_out <= ram_data_in;
            rd_addr_out <= rd_addr_in;
            ctrl_reg_write_out <= ctrl_reg_write_in;
            ctrl_mem_to_reg_out <= ctrl_mem_to_reg_in;
        end if;
    end process;
end Behavioral;
