----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/03/2026 12:23:36 AM
-- Design Name: 
-- Module Name: tb_branch_adder - Behavioral
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

entity tb_branch_adder is
end tb_branch_adder;

architecture behavioral of tb_branch_adder is

    component branch_adder
        Port (
            pc_in      : in  std_logic_vector(7 downto 0);
            imm_in     : in  std_logic_vector(7 downto 0);
            target_out : out std_logic_vector(7 downto 0)
        );
    end component;

    signal pc_in      : std_logic_vector(7 downto 0) := (others => '0');
    signal imm_in     : std_logic_vector(7 downto 0) := (others => '0');
    signal target_out : std_logic_vector(7 downto 0);

begin

    uut: branch_adder Port map (
        pc_in => pc_in,
        imm_in => imm_in,
        target_out => target_out
    );

    stim_proc: process
    begin
        pc_in <= x"00";
        imm_in <= x"00";
        wait for 20 ns;

        pc_in <= x"0A";
        imm_in <= x"05";
        wait for 20 ns;

        pc_in <= x"14";
        imm_in <= x"FB";
        wait for 20 ns;

        pc_in <= x"FA";
        imm_in <= x"0A";
        wait for 20 ns;

        pc_in <= x"80";
        imm_in <= x"80";
        wait for 20 ns;

        wait;
    end process;

end behavioral;
