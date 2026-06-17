library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity forwarding_unit is
    Port ( 
        rs1_addr_ex     : in std_logic_vector (2 downto 0);
        rs2_addr_ex     : in std_logic_vector (2 downto 0);
        rd_addr_mem     : in std_logic_vector (2 downto 0);
        reg_write_mem   : in std_logic;
        rd_addr_wb      : in std_logic_vector (2 downto 0);
        reg_write_wb    : in std_logic;
        forward_a       : out std_logic_vector (1 downto 0);
        forward_b       : out std_logic_vector (1 downto 0)
    );
end forwarding_unit;

architecture Behavioral of forwarding_unit is
begin
    process(rs1_addr_ex, rs2_addr_ex, rd_addr_mem, reg_write_mem, rd_addr_wb, reg_write_wb)
    begin
        forward_a <= "00";
        forward_b <= "00";

        if (reg_write_mem = '1' and rd_addr_mem /= "000" and rd_addr_mem = rs1_addr_ex) then
            forward_a <= "10"; 
        elsif (reg_write_wb = '1' and rd_addr_wb /= "000" and rd_addr_wb = rs1_addr_ex) then
            forward_a <= "01"; 
        end if;

        if (reg_write_mem = '1' and rd_addr_mem /= "000" and rd_addr_mem = rs2_addr_ex) then
            forward_b <= "10";
        elsif (reg_write_wb = '1' and rd_addr_wb /= "000" and rd_addr_wb = rs2_addr_ex) then
            forward_b <= "01";
        end if;
    end process;
end Behavioral;