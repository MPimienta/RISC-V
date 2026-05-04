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
    Port ( instruction_high : in STD_LOGIC_VECTOR (7 downto 0);
           instruction_low  : in STD_LOGIC_VECTOR (7 downto 0);
           immediate_out : out STD_LOGIC_VECTOR (7 downto 0));
end immediate_gen;

architecture Behavioral of immediate_gen is

    signal op_code : std_logic_vector (3 downto 0);

begin

    op_code <= instruction_high(7 downto 4);
    
    process(instruction_high, instruction_low, op_code)
    begin
        case op_code is
            -- operaciones que traen inmediatos de 6 bits
            when "0001" | "0010" | "0011" | "0101" | "0110" | "1000" => 
                if instruction_low(5) = '1' then
                    immediate_out <= "11" & instruction_low(5 downto 0);
                else 
                    immediate_out <= "00" & instruction_low(5 downto 0);
                end if;
            -- operaciones que traen inmediatos de 9 bits
            when "0100" | "0111" =>
                immediate_out <= instruction_low(7 downto 0);
            when others =>
                immediate_out <= "00000000";
        end case;
    end process;




end Behavioral;
