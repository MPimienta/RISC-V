----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/25/2026 09:48:35 PM
-- Design Name: 
-- Module Name: prog_counter - Structural
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

entity program_counter is
    Port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        load     : in  std_logic;                    -- Señal de la UC para saltos (BEQ/JAL)
        d_in     : in  std_logic_vector(7 downto 0); -- Dirección de destino del salto
        pc_out   : out std_logic_vector(7 downto 0)  -- Dirección actual para la memoria
    );
end program_counter;

architecture Behavioral of program_counter is
  
    signal pc_reg : unsigned(7 downto 0) := (others => '0');

begin

    process(clk, reset)
    begin
        if reset = '1' then
            -- Reseteo asíncrono a la dirección inicial
            pc_reg <= (others => '0');
            
        elsif rising_edge(clk) then
            if load = '1' then
                pc_reg <= unsigned(d_in);
            else
                pc_reg <= pc_reg + 1;
            end if;
        end if;
    end process;

    pc_out <= std_logic_vector(pc_reg);

end Behavioral;
