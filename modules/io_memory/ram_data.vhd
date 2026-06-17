----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/25/2026 09:48:35 PM
-- Design Name: 
-- Module Name: ram_data - Structural
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

entity ram_data is
    Port ( 
        write_en        :   in std_logic ;
        data_in         :   in std_logic_vector (15 downto 0);
        data_out        :   out std_logic_vector (15 downto 0);
        data_addr       :   in std_logic_vector (15 downto 0);
        clk             :   in std_logic 
    );
end ram_data;

architecture Behavioral of ram_data is

    type ram_array is array (0 to 1023) of STD_LOGIC_VECTOR(15 downto 0);
    
    signal ram : ram_array := (others => x"0000");

begin

    process(clk)
    begin 
        if rising_edge(clk) then
            if write_en = '1' then
                ram(to_integer(unsigned(data_addr(9 downto 0)))) <= data_in;
            end if;
        end if;
    end process;
    
    data_out <= ram(to_integer(unsigned(data_addr(9 downto 0))));


end Behavioral;
