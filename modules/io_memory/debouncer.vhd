----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/25/2026 09:48:35 PM
-- Design Name: 
-- Module Name: debouncer - Structural
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity debouncer is
    Port ( 
        clk     : in std_logic;
        reset   : in std_logic;
        btn_in  : in std_logic;
        btn_out : out std_logic 
    );
end debouncer;

architecture Behavioral of debouncer is

    signal count : unsigned (19 downto 0) := (others => '0');
    signal btn_prev : std_logic := '0';
    signal btn_stable : std_logic := '0';

begin

    process(clk)
    begin
        if rising_edge (clk) then
            if reset = '1' then
                count <= (others => '0');
                btn_out <= '0';
                btn_stable <= '0';
                btn_prev <= '0';
            else
                if btn_in /= btn_prev then
                    count <= (others => '0');
                    btn_prev <= btn_in;
                elsif count < 1000000 then
                    count <= count + 1;
                else
                    btn_stable <= btn_prev;
                end if;
                
                if btn_stable = '0' and btn_prev = '1' and count = 1000000 then
                    btn_out <= '1';
                else
                    btn_out <= '0';
                end if;
            end if;
        end if;                    
    end process;

end Behavioral;
