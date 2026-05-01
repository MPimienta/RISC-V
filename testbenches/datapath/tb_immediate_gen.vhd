----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/29/2026 10:45:06 PM
-- Design Name: 
-- Module Name: tb_immediate_gen - Behavioral
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

entity tb_immetiate_gen is
end tb_immetiate_gen;

architecture Behavioral of tb_immetiate_gen is

    component immediate_gen
    Port ( 
        instruction : in  STD_LOGIC_VECTOR (15 downto 0);
        immediate_out     : out STD_LOGIC_VECTOR (7 downto 0)
    );
    end component;

    signal instruction : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal immediate_out     : STD_LOGIC_VECTOR (7 downto 0);

begin

    uut: immediate_gen PORT MAP (
          instruction => instruction,
          immediate_out => immediate_out
        );

    stim_proc: process
    begin		

        instruction <= x"300F";
        wait for 20 ns; 

        instruction <= x"303B";
        wait for 20 ns;

        instruction <= x"40C8";
        wait for 20 ns;

        instruction <= x"0000";
        wait for 20 ns;

        wait;
    end process;

end Behavioral;