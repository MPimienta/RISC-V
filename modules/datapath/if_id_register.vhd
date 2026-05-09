----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/09/2026 01:26:48 PM
-- Design Name: 
-- Module Name: if_id_register - Behavioral
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

entity if_id_register is
    Port ( 
        clk                 : in std_logic;
        reset               : in std_logic;
        en                  : in std_logic; -- Manejar Data Hazard, da tiempo a instrucciones de memoria para guardar el dato
        flush               : in std_logic; -- Manejar Control Hazard, vaciar en caso de salto
        pc_in               : in std_logic_vector (15 downto 0);
        instruction_in      : in std_logic_vector (15 downto 0);
        
        pc_out              : out std_logic_vector (15 downto 0);
        instruction_out     : out std_logic_vector (15 downto 0)
        );
end if_id_register;

architecture Behavioral of if_id_register is

begin

    process(clk, reset)
    begin
        if (reset = '1') then
            instruction_out <= (others => '0');
            pc_out <= (others => '0');
        elsif rising_edge(clk) then
            if (flush = '1') then
                instruction_out <= (others => '0');
                pc_out <= (others => '0');
            elsif (en = '1') then
                pc_out <= pc_in;
                instruction_out <= instruction_in;
            end if;
        end if;
    end process;

end Behavioral;
