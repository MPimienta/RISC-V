library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity riscv is
    Port (
        clk         : in std_logic;
        reset       : in std_logic;
        inst_addr   : out std_logic_vector (15 downto 0);
        instruction : in  std_logic_vector (15 downto 0);
        write_en    : out std_logic;
        data_addr   : out std_logic_vector (15 downto 0);
        data_out    : out std_logic_vector (15 downto 0);
        data_in     : in  std_logic_vector (15 downto 0)
    );
end riscv;

architecture Structural of riscv is
    component registers is
        Port( clk, reset, reg_write : in std_logic;                      
              rs1_addr, rs2_addr, rd_addr : in std_logic_vector (2 downto 0);   
              write_data : in std_logic_vector (15 downto 0);   
              rs1_data, rs2_data : out std_logic_vector (15 downto 0));
    end component;

    component ALU is
        Port ( A, B : in std_logic_vector (15 downto 0); 
               ALU_Sel : in std_logic_vector (2 downto 0); 
               Result : out std_logic_vector (15 downto 0);
               Zero : out std_logic );
    end component;

    component branch_adder is
        Port ( pc_in, imm_in : in STD_LOGIC_VECTOR (15 downto 0);
               target_out : out STD_LOGIC_VECTOR (15 downto 0));
    end component;

    component control_unit is
        Port ( opcode : in std_logic_vector(3 downto 0); funct : in std_logic_vector(2 downto 0);
               alu_sel : out std_logic_vector(2 downto 0);
               alu_src_b, mem_write, reg_write, mem_to_reg : out std_logic;
               branch_eq, branch_neq, jump_jal, jump_jalr : out std_logic);
    end component;

    component immediate_gen is
        Port ( instruction : in STD_LOGIC_VECTOR (15 downto 0);
               immediate_out : out STD_LOGIC_VECTOR (15 downto 0));
    end component;

    component program_counter is
        Port ( clk, reset, pc_en : in std_logic;                    
               d_in : in std_logic_vector(15 downto 0); 
               pc_out : out std_logic_vector(15 downto 0));
    end component;

    component forwarding_unit is
        Port ( rs1_addr_ex, rs2_addr_ex, rd_addr_mem : in std_logic_vector (2 downto 0);
               reg_write_mem : in std_logic; rd_addr_wb : in std_logic_vector (2 downto 0);
               reg_write_wb : in std_logic;
               forward_a, forward_b : out std_logic_vector (1 downto 0));
    end component;

    component hazard_unit is
        Port ( rs1_addr_id, rs2_addr_id, rd_addr_ex : in std_logic_vector (2 downto 0);
               mem_to_reg_ex, branch_taken : in std_logic; 
               pc_en, if_id_en, if_id_flush, id_ex_flush : out std_logic);
    end component;

    -- Registros de Pipeline
    component if_id_register is
        Port ( clk, reset, en, flush : in std_logic;
               pc_in, instruction_in : in std_logic_vector (15 downto 0);
               pc_out, instruction_out : out std_logic_vector (15 downto 0));
    end component;

    component id_ex_register is
        Port ( clk, reset, flush : in std_logic;
               pc_in, rs1_data_in, rs2_data_in, imm_in : in std_logic_vector (15 downto 0);
               rs1_addr_in, rs2_addr_in, rd_addr_in : in std_logic_vector (2 downto 0);
               ctrl_alu_sel_in : in std_logic_vector (2 downto 0);
               ctrl_alu_src_b_in, ctrl_mem_write_in, ctrl_reg_write_in, ctrl_mem_to_reg_in : in std_logic;
               ctrl_branch_eq_in, ctrl_branch_neq_in, ctrl_jump_jal_in, ctrl_jump_jalr_in : in std_logic;
               pc_out, rs1_data_out, rs2_data_out, imm_out : out std_logic_vector (15 downto 0);
               rs1_addr_out, rs2_addr_out, rd_addr_out : out std_logic_vector (2 downto 0);
               ctrl_alu_sel_out : out std_logic_vector (2 downto 0);
               ctrl_alu_src_b_out, ctrl_mem_write_out, ctrl_reg_write_out, ctrl_mem_to_reg_out : out std_logic;
               ctrl_branch_eq_out, ctrl_branch_neq_out, ctrl_jump_jal_out, ctrl_jump_jalr_out : out std_logic);
    end component;

    component ex_mem_register is
        Port ( clk, reset : in std_logic;
               alu_result_in, rs2_data_in : in std_logic_vector (15 downto 0);
               rd_addr_in : in std_logic_vector (2 downto 0);
               ctrl_mem_write_in, ctrl_reg_write_in, ctrl_mem_to_reg_in : in std_logic;
               alu_result_out, rs2_data_out : out std_logic_vector (15 downto 0);
               rd_addr_out : out std_logic_vector (2 downto 0);
               ctrl_mem_write_out, ctrl_reg_write_out, ctrl_mem_to_reg_out : out std_logic);
    end component;

    component mem_wb_register is
        Port ( clk, en, flush, reset : in std_logic;
               alu_result_in, ram_data_in : in std_logic_vector (15 downto 0);
               rd_addr_in : in std_logic_vector (2 downto 0);
               ctrl_reg_write_in, ctrl_mem_to_reg_in : in std_logic;
               alu_result_out, ram_data_out : out std_logic_vector (15 downto 0);
               rd_addr_out : out std_logic_vector (2 downto 0);
               ctrl_reg_write_out, ctrl_mem_to_reg_out : out std_logic);
    end component;

    -- =========================================================
    -- SEÑALES INTERNAS DEL PIPELINE
    -- =========================================================
    
    -- Etapa FETCH
    signal if_pc_current, if_pc_next : std_logic_vector(15 downto 0);

    -- Etapa DECODE
    signal if_id_pc, if_id_inst : std_logic_vector(15 downto 0);
    signal id_rs1_addr, id_rs2_addr, id_rd_addr : std_logic_vector(2 downto 0);
    signal id_rs1_data, id_rs2_data, id_imm_ext : std_logic_vector(15 downto 0);
    signal ctrl_alu_sel : std_logic_vector(2 downto 0);
    signal ctrl_alu_src_b, ctrl_mem_write, ctrl_reg_write, ctrl_mem_to_reg : std_logic;
    signal ctrl_branch_eq, ctrl_branch_neq, ctrl_jump_jal, ctrl_jump_jalr : std_logic;

    -- Etapa EXECUTE
    signal id_ex_pc, id_ex_rs1_data, id_ex_rs2_data, id_ex_imm : std_logic_vector(15 downto 0);
    signal id_ex_rs1_addr, id_ex_rs2_addr, id_ex_rd_addr : std_logic_vector(2 downto 0);
    signal id_ex_alu_sel : std_logic_vector(2 downto 0);
    signal id_ex_alu_src_b, id_ex_mem_write, id_ex_reg_write, id_ex_mem_to_reg : std_logic;
    signal id_ex_br_eq, id_ex_br_neq, id_ex_j_jal, id_ex_j_jalr : std_logic;
    signal forward_a, forward_b : std_logic_vector(1 downto 0);
    signal alu_mux_a_out, alu_mux_b_out, alu_operando_b, ex_alu_result : std_logic_vector(15 downto 0);
    signal ex_zero_flag, ex_branch_taken : std_logic;
    signal ex_branch_target : std_logic_vector(15 downto 0);
    signal alu_result_internal : std_logic_vector(15 downto 0);
    signal branch_base_addr    : std_logic_vector(15 downto 0);

    -- Etapa MEMORY
    signal ex_mem_alu_res, ex_mem_rs2_data : std_logic_vector(15 downto 0);
    signal ex_mem_rd_addr : std_logic_vector(2 downto 0);
    signal ex_mem_mem_write, ex_mem_reg_write, ex_mem_mem_to_reg : std_logic;

    -- Etapa WRITEBACK
    signal mem_wb_alu_res, mem_wb_ram_data : std_logic_vector(15 downto 0);
    signal mem_wb_rd_addr : std_logic_vector(2 downto 0);
    signal mem_wb_reg_write, mem_wb_mem_to_reg : std_logic;
    signal wb_write_data : std_logic_vector(15 downto 0);

    -- Hazards
    signal hz_pc_en, hz_if_id_en, hz_if_id_flush, hz_id_ex_flush : std_logic;

begin

    inst_addr <= if_pc_current; 
    data_addr <= ex_mem_alu_res; 
    data_out  <= ex_mem_rs2_data; 
    write_en  <= ex_mem_mem_write;


    -- =========================================================
    -- 1. FETCH (IF)
    -- =========================================================
    if_pc_next <= ex_branch_target when ex_branch_taken = '1' else std_logic_vector(unsigned(if_pc_current) + 1);

    inst_PC: program_counter port map (
        clk => clk, reset => reset, pc_en => hz_pc_en, 
        d_in => if_pc_next, pc_out => if_pc_current
    );

    reg_if_id: if_id_register port map (
        clk => clk, reset => reset, en => hz_if_id_en, flush => hz_if_id_flush,
        pc_in => if_pc_current, instruction_in => instruction,
        pc_out => if_id_pc, instruction_out => if_id_inst
    );

    -- =========================================================
    -- 2. DECODE (ID)
    -- =========================================================
    id_rs1_addr <= if_id_inst(8 downto 6);
    id_rd_addr  <= if_id_inst(11 downto 9);

    id_rs2_addr <= if_id_inst(11 downto 9) when if_id_inst(15 downto 12) = "0010" or 
                                                if_id_inst(15 downto 12) = "0101" or 
                                                if_id_inst(15 downto 12) = "0110" 
                   else if_id_inst(5 downto 3);

    inst_Regs: registers port map (
        clk => clk, reset => reset, reg_write => mem_wb_reg_write,
        rs1_addr => id_rs1_addr, rs2_addr => id_rs2_addr, rd_addr => mem_wb_rd_addr,
        write_data => wb_write_data, rs1_data => id_rs1_data, rs2_data => id_rs2_data
    );

    inst_ImmGen: immediate_gen port map (
        instruction => if_id_inst, immediate_out => id_imm_ext
    );

    inst_CU: control_unit port map (
        opcode => if_id_inst(15 downto 12), funct => if_id_inst(2 downto 0),
        alu_sel => ctrl_alu_sel, alu_src_b => ctrl_alu_src_b, mem_write => ctrl_mem_write,
        reg_write => ctrl_reg_write, mem_to_reg => ctrl_mem_to_reg,
        branch_eq => ctrl_branch_eq, branch_neq => ctrl_branch_neq,
        jump_jal => ctrl_jump_jal, jump_jalr => ctrl_jump_jalr
    );

    inst_Hazard: hazard_unit port map (
        rs1_addr_id => id_rs1_addr, rs2_addr_id => id_rs2_addr,
        rd_addr_ex => id_ex_rd_addr, mem_to_reg_ex => id_ex_mem_to_reg,
        branch_taken => ex_branch_taken,
        pc_en => hz_pc_en, if_id_en => hz_if_id_en,
        if_id_flush => hz_if_id_flush, id_ex_flush => hz_id_ex_flush
    );

    reg_id_ex: id_ex_register port map (
        clk => clk, reset => reset, flush => hz_id_ex_flush,
        pc_in => if_id_pc, rs1_data_in => id_rs1_data, rs2_data_in => id_rs2_data, imm_in => id_imm_ext,
        rs1_addr_in => id_rs1_addr, rs2_addr_in => id_rs2_addr, rd_addr_in => id_rd_addr,
        ctrl_alu_sel_in => ctrl_alu_sel, ctrl_alu_src_b_in => ctrl_alu_src_b,
        ctrl_mem_write_in => ctrl_mem_write, ctrl_reg_write_in => ctrl_reg_write,
        ctrl_mem_to_reg_in => ctrl_mem_to_reg,
        ctrl_branch_eq_in => ctrl_branch_eq, ctrl_branch_neq_in => ctrl_branch_neq,
        ctrl_jump_jal_in => ctrl_jump_jal, ctrl_jump_jalr_in => ctrl_jump_jalr,
        pc_out => id_ex_pc, rs1_data_out => id_ex_rs1_data, rs2_data_out => id_ex_rs2_data, imm_out => id_ex_imm,
        rs1_addr_out => id_ex_rs1_addr, rs2_addr_out => id_ex_rs2_addr, rd_addr_out => id_ex_rd_addr,
        ctrl_alu_sel_out => id_ex_alu_sel, ctrl_alu_src_b_out => id_ex_alu_src_b,
        ctrl_mem_write_out => id_ex_mem_write, ctrl_reg_write_out => id_ex_reg_write,
        ctrl_mem_to_reg_out => id_ex_mem_to_reg,
        ctrl_branch_eq_out => id_ex_br_eq, ctrl_branch_neq_out => id_ex_br_neq,
        ctrl_jump_jal_out => id_ex_j_jal, ctrl_jump_jalr_out => id_ex_j_jalr
    );

    -- =========================================================
    -- 3. EXECUTE (EX)
    -- =========================================================
    inst_Forward: forwarding_unit port map (
        rs1_addr_ex => id_ex_rs1_addr, rs2_addr_ex => id_ex_rs2_addr,
        rd_addr_mem => ex_mem_rd_addr, reg_write_mem => ex_mem_reg_write,
        rd_addr_wb => mem_wb_rd_addr, reg_write_wb => mem_wb_reg_write,
        forward_a => forward_a, forward_b => forward_b
    );

    alu_mux_a_out <= ex_mem_alu_res when forward_a = "10" else
                     wb_write_data  when forward_a = "01" else
                     id_ex_rs1_data;

    alu_mux_b_out <= ex_mem_alu_res when forward_b = "10" else
                     wb_write_data  when forward_b = "01" else
                     id_ex_rs2_data;

    alu_operando_b <= id_ex_imm when id_ex_alu_src_b = '1' else alu_mux_b_out;

    inst_ALU: ALU port map (
        A => alu_mux_a_out, B => alu_operando_b, ALU_Sel => id_ex_alu_sel, 
        Result => alu_result_internal, Zero => ex_zero_flag
    );

    ex_alu_result <= std_logic_vector(unsigned(id_ex_pc) + 1) when (id_ex_j_jal = '1' or id_ex_j_jalr = '1') else alu_result_internal;
    branch_base_addr <= alu_mux_a_out when id_ex_j_jalr = '1' else id_ex_pc;

    inst_BranchAdd: branch_adder port map (
        pc_in => branch_base_addr, imm_in => id_ex_imm, target_out => ex_branch_target
    );

    ex_branch_taken <= '1' when (id_ex_j_jal = '1' or id_ex_j_jalr = '1' or 
                                (id_ex_br_eq = '1' and ex_zero_flag = '1') or
                                (id_ex_br_neq = '1' and ex_zero_flag = '0')) else '0';

    reg_ex_mem: ex_mem_register port map (
        clk => clk, reset => reset,
        alu_result_in => ex_alu_result, rs2_data_in => alu_mux_b_out,
        rd_addr_in => id_ex_rd_addr, ctrl_mem_write_in => id_ex_mem_write,
        ctrl_reg_write_in => id_ex_reg_write, ctrl_mem_to_reg_in => id_ex_mem_to_reg,
        alu_result_out => ex_mem_alu_res, rs2_data_out => ex_mem_rs2_data,
        rd_addr_out => ex_mem_rd_addr, ctrl_mem_write_out => ex_mem_mem_write,
        ctrl_reg_write_out => ex_mem_reg_write, ctrl_mem_to_reg_out => ex_mem_mem_to_reg
    );

    -- =========================================================
    -- 4. MEMORY (MEM)
    -- =========================================================
    
    reg_mem_wb: mem_wb_register port map (
        clk => clk, reset => reset, en => '1', flush => '0',
        alu_result_in => ex_mem_alu_res, 
        ram_data_in => data_in, 
        rd_addr_in => ex_mem_rd_addr,
        ctrl_reg_write_in => ex_mem_reg_write, ctrl_mem_to_reg_in => ex_mem_mem_to_reg,
        alu_result_out => mem_wb_alu_res, ram_data_out => mem_wb_ram_data,
        rd_addr_out => mem_wb_rd_addr, ctrl_reg_write_out => mem_wb_reg_write,
        ctrl_mem_to_reg_out => mem_wb_mem_to_reg
    );

    -- =========================================================
    -- 5. WRITEBACK (WB)
    -- =========================================================
    wb_write_data <= mem_wb_ram_data when mem_wb_mem_to_reg = '1' else mem_wb_alu_res;

end Structural;