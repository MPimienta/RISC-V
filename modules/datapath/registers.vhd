----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/25/2026 09:48:35 PM
-- Design Name: 
-- Module Name: registers - Structural
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity registers is
    Port(
        clk         :   in std_logic ;
        reset       :   in std_logic ;
        reg_write   :   in std_logic ; 
        
        rs1_addr    :   in std_logic_vector (2 downto 0); 
        rs2_addr    :   in std_logic_vector (2 downto 0); 
        rd_addr     :   in std_logic_vector (2 downto 0);  
        
        write_data  :   in std_logic_vector (15 downto 0);   
        rs1_data    :   out std_logic_vector (15 downto 0);  
        rs2_data    :   out std_logic_vector (15 downto 0)  
        
    );
end registers;

architecture Behavioral of registers is
    type reg_array is array (0 to 7) of std_logic_vector(15 downto 0);
    signal regs : reg_array := (others => x"0000");
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                regs <= (others => x"0000");
            elsif reg_write = '1' and rd_addr /= "000" then
                regs(to_integer(unsigned(rd_addr))) <= write_data;
            end if;
        end if;
    end process;

    -- forwarding y lectura
    rs1_data <= write_data when (reg_write = '1' and rd_addr = rs1_addr and rd_addr /= "000") else 
                regs(to_integer(unsigned(rs1_addr)));
                
    rs2_data <= write_data when (reg_write = '1' and rd_addr = rs2_addr and rd_addr /= "000") else 
                regs(to_integer(unsigned(rs2_addr)));
    
end Behavioral;
