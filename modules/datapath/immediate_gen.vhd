----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/29/2026 10:33:35 PM
-- Design Name: 
-- Module Name: immediate_gen - Behavioral
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

entity immediate_gen is
    Port ( instruction   : in STD_LOGIC_VECTOR (15 downto 0);
           immediate_out : out STD_LOGIC_VECTOR (15 downto 0));
end immediate_gen;

architecture Behavioral of immediate_gen is

    signal op_code : std_logic_vector (3 downto 0);

begin

    op_code <= instruction(15 downto 12);
    
    process(instruction, op_code)
    begin
        case op_code is
            -- operaciones que traen inmediatos de 6 bits
            when "0001" | "0010" | "0011" | "0101" | "0110" | "1000" => 
                if instruction(5) = '1' then
                    immediate_out <= "1111111111" & instruction(5 downto 0);
                else 
                    immediate_out <= "0000000000" & instruction(5 downto 0);
                end if;
            -- operaciones que traen inmediatos de 9 bits
            when "0100" | "0111" =>
                if instruction(8) = '1' then
                    immediate_out <= "1111111" & instruction(8 downto 0);
                else
                    immediate_out <= "0000000" & instruction(8 downto 0);
                end if;
            when others =>
                immediate_out <= "0000000000000000";
        end case;
    end process;


end Behavioral;
