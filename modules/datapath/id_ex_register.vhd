library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity id_ex_register is
Port (
clk     : in std_logic ;
reset   : in std_logic ;
flush   : in std_logic ; -- Usado por la Hazard Unit para "limpiar" instrucciones
en      : in std_logic ;

    -- Datos de entrada
    pc_in       : in std_logic_vector (15 downto 0);
    rs1_data_in : in std_logic_vector (15 downto 0);
    rs2_data_in : in std_logic_vector (15 downto 0);
    imm_in      : in std_logic_vector (15 downto 0);
    rs1_addr_in : in std_logic_vector (2 downto 0);
    rs2_addr_in : in std_logic_vector (2 downto 0);
    rd_addr_in  : in std_logic_vector (2 downto 0);
    
    -- Señales de Control de entrada (ID)
    ctrl_alu_sel_in     : in std_logic_vector (2 downto 0);
    ctrl_alu_src_b_in   : in std_logic;
    ctrl_mem_write_in   : in std_logic;
    ctrl_reg_write_in   : in std_logic;
    ctrl_mem_to_reg_in  : in std_logic;
    
    -- SEÑALES FALTANTES: Control de Saltos
    ctrl_branch_eq_in   : in std_logic;
    ctrl_branch_neq_in  : in std_logic;
    ctrl_jump_jal_in    : in std_logic;
    ctrl_jump_jalr_in   : in std_logic;
    
    -- Datos de salida (Hacia etapa EX)
    pc_out          : out std_logic_vector (15 downto 0);
    rs1_data_out    : out std_logic_vector (15 downto 0);
    rs2_data_out    : out std_logic_vector (15 downto 0);
    imm_out         : out std_logic_vector (15 downto 0);
    rs1_addr_out    : out std_logic_vector (2 downto 0);
    rs2_addr_out    : out std_logic_vector (2 downto 0);
    rd_addr_out     : out std_logic_vector (2 downto 0);
    
    -- Señales de Control de salida (EX)
    ctrl_alu_sel_out    : out std_logic_vector (2 downto 0);
    ctrl_alu_src_b_out  : out std_logic;
    ctrl_mem_write_out  : out std_logic;
    ctrl_reg_write_out  : out std_logic;
    ctrl_mem_to_reg_out : out std_logic;
    
    -- SEÑALES FALTANTES: Control de Saltos (Salida)
    ctrl_branch_eq_out  : out std_logic;
    ctrl_branch_neq_out : out std_logic;
    ctrl_jump_jal_out   : out std_logic;
    ctrl_jump_jalr_out  : out std_logic
);


end id_ex_register;

architecture Behavioral of id_ex_register is
begin
process(clk, reset)
begin
if (reset = '1') then
pc_out <= (others => '0');
rs1_data_out <= (others => '0');
rs2_data_out <= (others => '0');
imm_out <= (others => '0');
rs1_addr_out <= (others => '0');
rs2_addr_out <= (others => '0');
rd_addr_out <= (others => '0');

        ctrl_alu_sel_out <= (others => '0');
        ctrl_alu_src_b_out <= '0';
        ctrl_mem_write_out <= '0';
        ctrl_reg_write_out <= '0';
        ctrl_mem_to_reg_out <= '0';
        
        ctrl_branch_eq_out <= '0';
        ctrl_branch_neq_out <= '0';
        ctrl_jump_jal_out <= '0';
        ctrl_jump_jalr_out <= '0';
        
    elsif rising_edge(clk) then
        if (flush = '1') then
            pc_out <= (others => '0');
            rs1_data_out <= (others => '0');
            rs2_data_out <= (others => '0');
            imm_out <= (others => '0');
            rs1_addr_out <= (others => '0');
            rs2_addr_out <= (others => '0');
            rd_addr_out <= (others => '0');
            
            ctrl_alu_sel_out <= (others => '0');
            ctrl_alu_src_b_out <= '0';
            ctrl_mem_write_out <= '0';
            ctrl_reg_write_out <= '0';
            ctrl_mem_to_reg_out <= '0';
            
            ctrl_branch_eq_out <= '0';
            ctrl_branch_neq_out <= '0';
            ctrl_jump_jal_out <= '0';
            ctrl_jump_jalr_out <= '0';

        elsif (en = '1') then
            pc_out <= pc_in;
            rs1_data_out <= rs1_data_in;
            rs2_data_out <= rs2_data_in;
            imm_out <= imm_in;
            rs1_addr_out <= rs1_addr_in;
            rs2_addr_out <= rs2_addr_in;
            rd_addr_out <= rd_addr_in;
            
            ctrl_alu_sel_out <= ctrl_alu_sel_in;
            ctrl_alu_src_b_out <= ctrl_alu_src_b_in;
            ctrl_mem_write_out <= ctrl_mem_write_in;
            ctrl_reg_write_out <= ctrl_reg_write_in;
            ctrl_mem_to_reg_out <= ctrl_mem_to_reg_in;
            
            ctrl_branch_eq_out <= ctrl_branch_eq_in;
            ctrl_branch_neq_out <= ctrl_branch_neq_in;
            ctrl_jump_jal_out <= ctrl_jump_jal_in;
            ctrl_jump_jalr_out <= ctrl_jump_jalr_in;
        end if;
    end if;
end process;


end Behavioral;