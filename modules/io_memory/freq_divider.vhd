----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/21/2026 08:24:32 PM
-- Design Name: 
-- Module Name: freq_divider - Behavioral
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

entity freq_divider is
    Port ( clk_in : in STD_LOGIC;
           clk_out : out STD_LOGIC);
end freq_divider;

architecture Behavioral of freq_divider is

    signal clk_div_counter  : integer := 0;
    signal clk_10mhz        : std_logic := '0';

begin

    process(clk_in)
    begin
        if rising_edge(clk_in) then
            if clk_div_counter = 4 then
                clk_10mhz <= not clk_10mhz;
                clk_div_counter <= 0;
            else
                clk_div_counter <= clk_div_counter + 1;
            end if;
        end if;
    end process;
    
    clk_out <= clk_10mhz;


end Behavioral;
