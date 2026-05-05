----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/03/2026 12:21:08 AM
-- Design Name: 
-- Module Name: branch_adder - Behavioral
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

entity branch_adder is
    Port ( pc_in : in STD_LOGIC_VECTOR (15 downto 0);
           imm_in : in STD_LOGIC_VECTOR (15 downto 0);
           target_out : out STD_LOGIC_VECTOR (15 downto 0));
end branch_adder;

architecture Behavioral of branch_adder is
begin

    target_out <= std_logic_vector(unsigned(pc_in) + unsigned(imm_in));

end Behavioral;
