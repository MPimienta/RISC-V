----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/03/2026 12:02:58 AM
-- Design Name: 
-- Module Name: tb_decoder - Behavioral
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

entity tb_decoder is
end tb_decoder;

architecture behavioral of tb_decoder is

    component decoder
        Port (
            clk          : in std_logic;
            reset        : in std_logic;
            cpu_addr     : in std_logic_vector(7 downto 0);
            cpu_data_in  : in std_logic_vector(7 downto 0);
            cpu_mem_write: in std_logic;
            cpu_data_out : out std_logic_vector(7 downto 0);
            ram_data_out : in std_logic_vector(7 downto 0);
            ram_we       : out std_logic;
            switches_in  : in std_logic_vector(7 downto 0);
            buttons_in   : in std_logic_vector(7 downto 0);
            leds_out     : out std_logic_vector(7 downto 0);
            display_out  : out std_logic_vector(7 downto 0)
        );
    end component;

    signal clk          : std_logic := '0';
    signal reset        : std_logic := '1';
    signal cpu_addr     : std_logic_vector(7 downto 0) := (others => '0');
    signal cpu_data_in  : std_logic_vector(7 downto 0) := (others => '0');
    signal cpu_mem_write: std_logic := '0';
    signal cpu_data_out : std_logic_vector(7 downto 0);
    signal ram_data_out : std_logic_vector(7 downto 0) := (others => '0');
    signal ram_we       : std_logic;
    signal switches_in  : std_logic_vector(7 downto 0) := (others => '0');
    signal buttons_in   : std_logic_vector(7 downto 0) := (others => '0');
    signal leds_out     : std_logic_vector(7 downto 0);
    signal display_out  : std_logic_vector(7 downto 0);

    constant clk_period : time := 10 ns;

begin

    uut: decoder Port map (
        clk => clk,
        reset => reset,
        cpu_addr => cpu_addr,
        cpu_data_in => cpu_data_in,
        cpu_mem_write => cpu_mem_write,
        cpu_data_out => cpu_data_out,
        ram_data_out => ram_data_out,
        ram_we => ram_we,
        switches_in => switches_in,
        buttons_in => buttons_in,
        leds_out => leds_out,
        display_out => display_out
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
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;

        ram_data_out <= x"AA";
        cpu_addr <= x"10";
        wait for clk_period;

        cpu_addr <= x"10";
        cpu_data_in <= x"BB";
        cpu_mem_write <= '1';
        wait for clk_period;
        cpu_mem_write <= '0';
        wait for clk_period;

        switches_in <= x"CC";
        cpu_addr <= x"E0";
        wait for clk_period;

        buttons_in <= x"DD";
        cpu_addr <= x"E1";
        wait for clk_period;

        cpu_addr <= x"F0";
        cpu_data_in <= x"EE";
        cpu_mem_write <= '1';
        wait for clk_period;
        cpu_mem_write <= '0';
        wait for clk_period;

        cpu_addr <= x"F1";
        cpu_data_in <= x"FF";
        cpu_mem_write <= '1';
        wait for clk_period;
        cpu_mem_write <= '0';
        wait for clk_period;

        cpu_addr <= x"FF";
        wait for clk_period;

        wait;
    end process;

end behavioral;
