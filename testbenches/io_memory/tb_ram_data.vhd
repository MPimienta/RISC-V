----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/30/2026 12:17:12 PM
-- Design Name: 
-- Module Name: tb_ram_data - Behavioral
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

entity tb_ram_data is
end tb_ram_data;

architecture Behavioral of tb_ram_data is

    component ram_data
    Port ( 
        write_en   : in std_logic;
        data_in    : in std_logic_vector (7 downto 0);
        data_out   : out std_logic_vector (7 downto 0);
        data_addr  : in std_logic_vector (7 downto 0);
        clk        : in std_logic 
    );
    end component;

    signal clk        : std_logic := '0';
    signal write_en   : std_logic := '0';
    signal data_in    : std_logic_vector(7 downto 0) := (others => '0');
    signal data_addr  : std_logic_vector(7 downto 0) := (others => '0');
    
    signal data_out   : std_logic_vector(7 downto 0);

    constant clk_period : time := 10 ns;

begin

    uut: ram_data PORT MAP (
        write_en  => write_en,
        data_in   => data_in,
        data_out  => data_out,
        data_addr => data_addr,
        clk       => clk
    );

    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
    begin		

        wait for 20 ns;	

        data_addr <= x"10";  
        write_en <= '0';     
        wait for clk_period;

        data_addr <= x"10";  
        data_in <= x"AA";   
        write_en <= '1';   
        wait for clk_period;
        
        write_en <= '0'; 
        wait for clk_period;

        data_addr <= x"10";  
        wait for clk_period;

        data_addr <= x"7F";  
        data_in <= x"BB";    
        write_en <= '1';
        wait for clk_period;
        write_en <= '0';
        wait for clk_period;

        data_addr <= x"FF";  
        wait for clk_period;
        
        wait;
    end process;

end Behavioral;