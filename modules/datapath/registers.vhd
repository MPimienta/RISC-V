----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/25/2026 09:48:35 PM
-- Design Name: 
-- Module Name: registers - Structural
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

entity registers is
    Port(
        clk         :   in std_logic ;
        reset       :   in std_logic ;
        reg_write   :   in std_logic ;                      -- Permitir escribir en un registro
        
        rs1_addr    :   in std_logic_vector (2 downto 0);   -- direccion del primer registro fuente
        rs2_addr    :   in std_logic_vector (2 downto 0);   -- direccion del segundo registro fuente
        rd_addr     :   in std_logic_vector (2 downto 0);   -- direccion del registro destino
        
        write_data  :   in std_logic_vector (7 downto 0);   -- datos de entrada para escribir en el registro
        rs1_data    :   out std_logic_vector (7 downto 0);   -- datos de salida del primer  registro fuente
        rs2_data    :   out std_logic_vector (7 downto 0)    -- datos de salida del segundo registro fuente
        
    );
end registers;

architecture Behavioral of registers is
    
    type reg_array is array (0 to 7) of STD_LOGIC_VECTOR(7 downto 0); -- 8 registros de 8 bits
    
    signal regs : reg_array := (others => "00000000");

begin

    rs1_data <= regs(to_integer(unsigned(rs1_addr)));
    rs2_data <= regs(to_integer(unsigned(rs2_addr)));

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                regs <= (others => "00000000");
            elsif reg_write = '1' then
                if rd_addr /= "000" then
                    regs(to_integer(unsigned(rd_addr))) <= write_data;
                end if;
            end if;
        end if;
    end process;
    
end Behavioral;
