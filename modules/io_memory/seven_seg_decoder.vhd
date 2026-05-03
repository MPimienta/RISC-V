----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/03/2026 05:54:14 PM
-- Design Name: 
-- Module Name: seven_seg_decoder - DataFlow
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

entity seven_seg_decoder is
    Port ( 
        hex_in  : in  std_logic_vector (3 downto 0);
        seg_out : out std_logic_vector (6 downto 0)
    );
end seven_seg_decoder;

architecture Dataflow of seven_seg_decoder is
begin
    -- Mapeo de Hexadecimal a 7 segmentos ('0' enciende)
    -- seg_out es (g f e d c b a)
    with hex_in select
        seg_out <= "1000000" when x"0", 
                   "1111001" when x"1", 
                   "0100100" when x"2", 
                   "0110000" when x"3", 
                   "0011001" when x"4", 
                   "0010010" when x"5", 
                   "0000010" when x"6", 
                   "1111000" when x"7", 
                   "0000000" when x"8", 
                   "0010000" when x"9", 
                   "0001000" when x"A", 
                   "0000011" when x"B", 
                   "1000110" when x"C", 
                   "0100001" when x"D", 
                   "0000110" when x"E", 
                   "0001110" when others; 
end Dataflow;
