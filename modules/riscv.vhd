library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity riscv is
Port (
    btn_clk     : in std_logic;
    clk         : in std_logic;
    btn_reset   : in std_logic;
    swt         : in std_logic_vector (15 downto 0);
    led         : out std_logic_vector (15 downto 0);
    seg         : out std_logic_vector (6 downto 0);
    dp          : out std_logic;
    an          : out std_logic_vector (3 downto 0);
    btn_add     : in std_logic ;
    btn_sub     : in std_logic ;
    --keypad
    keypad_col : in std_logic_vector(3 downto 0);
    keypad_row : out std_logic_vector(3 downto 0);
    -- lcd
    --lcd_sda : inout std_logic;
    --lcd_scl : inout std_logic
    -- Pines de la PmodOLED
    oled_cs       : out std_logic;
    oled_sdin     : out std_logic;
    oled_sclk     : out std_logic;
    oled_dc       : out std_logic;
    oled_res      : out std_logic;
    oled_vbat     : out std_logic;
    oled_vdd      : out std_logic
);
end riscv;

architecture Structural of riscv is

-- Componentes
component registers is
    Port(
        clk         : in std_logic;
        reset       : in std_logic;
        reg_write   : in std_logic;                      
        rs1_addr    : in std_logic_vector (2 downto 0);   
        rs2_addr    : in std_logic_vector (2 downto 0);   
        rd_addr     : in std_logic_vector (2 downto 0);   
        write_data  : in std_logic_vector (15 downto 0);   
        rs1_data    : out std_logic_vector (15 downto 0);  
        rs2_data    : out std_logic_vector (15 downto 0)    
    );
end component;

component ALU is
    Port ( 
        A       : in  std_logic_vector (15 downto 0); 
        B       : in  std_logic_vector (15 downto 0); 
        ALU_Sel : in  std_logic_vector (2 downto 0); 
        Result  : out std_logic_vector (15 downto 0);
        Zero    : out std_logic 
    );
end component;

component branch_adder is
    Port ( 
        pc_in       : in STD_LOGIC_VECTOR (15 downto 0);
        imm_in      : in STD_LOGIC_VECTOR (15 downto 0);
        target_out  : out STD_LOGIC_VECTOR (15 downto 0)
    );
end component;

component control_unit is
    Port (
        opcode      : in std_logic_vector(3 downto 0);
        funct       : in std_logic_vector(2 downto 0);
        alu_sel     : out std_logic_vector(2 downto 0);
        alu_src_b   : out std_logic;
        mem_write   : out std_logic;
        reg_write   : out std_logic;
        mem_to_reg  : out std_logic;
        branch_eq   : out std_logic;
        branch_neq  : out std_logic;
        jump_jal    : out std_logic;
        jump_jalr   : out std_logic
    );
end component;

component debouncer is
    Port ( 
        clk     : in std_logic;
        reset   : in std_logic;
        btn_in  : in std_logic;
        btn_out : out std_logic 
    );
end component;

component decoder is
    Port ( 
        clk           : in std_logic;
        reset         : in std_logic;
        cpu_addr      : in std_logic_vector(15 downto 0);
        cpu_data_in   : in std_logic_vector(15 downto 0); 
        cpu_mem_write : in std_logic;
        cpu_data_out  : out std_logic_vector(15 downto 0);
        ram_data_out  : in std_logic_vector(15 downto 0); 
        ram_we        : out std_logic;
        switches_in   : in std_logic_vector(15 downto 0);
        buttons_in    : in std_logic_vector(4 downto 0);
        keypad_data_in: in std_logic_vector(15 downto 0);
        leds_out      : out std_logic_vector(15 downto 0);
        display_out   : out std_logic_vector(15 downto 0);
        oled_data_out : in std_logic_vector(15 downto 0)
    );
end component;

component immediate_gen is
    Port ( 
        instruction   : in STD_LOGIC_VECTOR (15 downto 0);
        immediate_out : out STD_LOGIC_VECTOR (15 downto 0)
    );
end component;

component program_counter is
    Port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        pc_en    : in  std_logic;                    
        load     : in  std_logic;                    
        d_in     : in  std_logic_vector(15 downto 0); 
        pc_out   : out std_logic_vector(15 downto 0)
    );
end component;

component ram_data is
    Port ( 
        write_en        : in std_logic;
        data_in         : in std_logic_vector (15 downto 0);
        data_out        : out std_logic_vector (15 downto 0);
        data_addr       : in std_logic_vector (15 downto 0);
        clk             : in std_logic 
    );
end component;

component rom_instructions is
    Port (
        instruction_out     : out std_logic_vector(15 downto 0);
        instruction_addr    : in std_logic_vector (15 downto 0)   
    );
end component;

component seven_seg_decoder is
    Port (
        clk      : in  std_logic;                    
        reset    : in  std_logic;                    
        data_in  : in  std_logic_vector(15 downto 0); 
        seg      : out std_logic_vector(6 downto 0); 
        dp       : out std_logic;                    
        an       : out std_logic_vector(3 downto 0)  
    );
end component;

component forwarding_unit is
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
end component;

component hazard_unit is
    Port ( 
        rs1_addr_id     : in std_logic_vector (2 downto 0);
        rs2_addr_id     : in std_logic_vector (2 downto 0);
        rd_addr_ex      : in std_logic_vector (2 downto 0);
        mem_to_reg_ex   : in std_logic; 
        branch_taken    : in std_logic; 
        pc_en           : out std_logic; 
        if_id_en        : out std_logic; 
        if_id_flush     : out std_logic; 
        id_ex_flush     : out std_logic 
    );
end component;

-- Registros de Pipeline (Componentes internos)
component if_id_register is
    Port ( 
        clk : in std_logic; reset : in std_logic; en : in std_logic; flush : in std_logic;
        pc_in : in std_logic_vector (15 downto 0); instruction_in : in std_logic_vector (15 downto 0);
        pc_out : out std_logic_vector (15 downto 0); instruction_out : out std_logic_vector (15 downto 0)
    );
end component;

component id_ex_register is
    Port ( 
        clk, reset, flush, en : in std_logic;
        pc_in, rs1_data_in, rs2_data_in, imm_in : in std_logic_vector (15 downto 0);
        rs1_addr_in, rs2_addr_in, rd_addr_in : in std_logic_vector (2 downto 0);
        ctrl_alu_sel_in : in std_logic_vector (2 downto 0);
        ctrl_alu_src_b_in, ctrl_mem_write_in, ctrl_reg_write_in, ctrl_mem_to_reg_in : in std_logic;
        ctrl_branch_eq_in, ctrl_branch_neq_in, ctrl_jump_jal_in, ctrl_jump_jalr_in : in std_logic;
        pc_out, rs1_data_out, rs2_data_out, imm_out : out std_logic_vector (15 downto 0);
        rs1_addr_out, rs2_addr_out, rd_addr_out : out std_logic_vector (2 downto 0);
        ctrl_alu_sel_out : out std_logic_vector (2 downto 0);
        ctrl_alu_src_b_out, ctrl_mem_write_out, ctrl_reg_write_out, ctrl_mem_to_reg_out : out std_logic;
        ctrl_branch_eq_out, ctrl_branch_neq_out, ctrl_jump_jal_out, ctrl_jump_jalr_out : out std_logic
    );
end component;

component ex_mem_register is
    Port ( 
        clk, reset, en, flush : in std_logic;
        alu_result_in, rs2_data_in : in std_logic_vector (15 downto 0);
        rd_addr_in : in std_logic_vector (2 downto 0);
        ctrl_mem_write_in, ctrl_reg_write_in, ctrl_mem_to_reg_in : in std_logic;
        alu_result_out, rs2_data_out : out std_logic_vector (15 downto 0);
        rd_addr_out : out std_logic_vector (2 downto 0);
        ctrl_mem_write_out, ctrl_reg_write_out, ctrl_mem_to_reg_out : out std_logic
    );
end component;

component mem_wb_register is
    Port ( 
        clk, en, flush, reset : in std_logic;
        alu_result_in, ram_data_in : in std_logic_vector (15 downto 0);
        rd_addr_in : in std_logic_vector (2 downto 0);
        ctrl_reg_write_in, ctrl_mem_to_reg_in : in std_logic;
        alu_result_out, ram_data_out : out std_logic_vector (15 downto 0);
        rd_addr_out : out std_logic_vector (2 downto 0);
        ctrl_reg_write_out, ctrl_mem_to_reg_out : out std_logic
    );
end component;

component  keypad_controller is
    Port (
        clk         : in  STD_LOGIC; 
        reset       : in  STD_LOGIC;
        keypad_col  : in  STD_LOGIC_VECTOR (3 downto 0); 
        keypad_row  : out STD_LOGIC_VECTOR (3 downto 0); 
        data_out    : out STD_LOGIC_VECTOR (15 downto 0) 
    );
end component ;

component oled_spi_mmio is
    Port ( 
        clk, reset    : in std_logic;
        cpu_addr      : in std_logic_vector(15 downto 0);
        cpu_data_in   : in std_logic_vector(15 downto 0);
        cpu_we        : in std_logic;
        cpu_data_out  : out std_logic_vector(15 downto 0);
        oled_cs, oled_sdin, oled_sclk, oled_dc, oled_res, oled_vbat, oled_vdd : out std_logic
    );
end component;

signal oled_bus_out : std_logic_vector(15 downto 0);

signal keypad_data : std_logic_vector(15 downto 0);

-- Señales internas
signal clk_deb : std_logic;
signal display_val : std_logic_vector(15 downto 0);
signal clk_10mhz : std_logic := '0';
signal clk_div_counter : integer range 0 to 4 := 0;

-- Etapa FETCH
signal if_pc_current, if_pc_next, if_instruction : std_logic_vector(15 downto 0);

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
signal mem_ram_data_out, mem_dec_data_out, mem_cpu_data_in : std_logic_vector(15 downto 0);
signal dec_ram_we : std_logic;

-- Etapa WRITEBACK
signal mem_wb_alu_res, mem_wb_ram_data : std_logic_vector(15 downto 0);
signal mem_wb_rd_addr : std_logic_vector(2 downto 0);
signal mem_wb_reg_write, mem_wb_mem_to_reg : std_logic;
signal wb_write_data : std_logic_vector(15 downto 0);

-- Hazards
signal hz_pc_en, hz_if_id_en, hz_if_id_flush, hz_id_ex_flush : std_logic;

signal btn_array : std_logic_vector (4 downto 0);

signal mmio_display_data : std_logic_vector (15 downto 0);

begin

process(clk)
    begin
        if rising_edge(clk) then
            if clk_div_counter = 4 then
                clk_10mhz <= not clk_10mhz;
                clk_div_counter <= 0;
            else
                clk_div_counter <= clk_div_counter + 1;
            end if;
        end if;
    end process;
    
clk_deb <= clk_10mhz;

inst_Keypad: entity work.keypad_controller
port map (
    clk => clk,
    reset => btn_reset,
    keypad_col => keypad_col,
    keypad_row => keypad_row,
    data_out => keypad_data
);

-- 0. Reloj y Visualización
--deb_clk: debouncer port map (clk => clk, reset => btn_reset, btn_in => btn_clk, btn_out => clk_deb);
--clk_deb <= clk;



-- 1. FETCH (IF)
if_pc_next <= ex_branch_target when ex_branch_taken = '1' else std_logic_vector(unsigned(if_pc_current) + 1);

inst_PC: program_counter port map (
    clk => clk_deb, reset => btn_reset, pc_en => hz_pc_en, 
    load => '1', d_in => if_pc_next, pc_out => if_pc_current
);

inst_ROM: rom_instructions port map (
    instruction_addr => if_pc_current, instruction_out => if_instruction
);

reg_if_id: if_id_register port map (
    clk => clk_deb, reset => btn_reset, en => hz_if_id_en, flush => hz_if_id_flush,
    pc_in => if_pc_current, instruction_in => if_instruction,
    pc_out => if_id_pc, instruction_out => if_id_inst
);

-- 2. DECODE (ID)
id_rs1_addr <= if_id_inst(8 downto 6);
id_rd_addr  <= if_id_inst(11 downto 9);

-- Lógica RS2 corregida para instrucciones tipo S (SW) y B (Saltos)
id_rs2_addr <= if_id_inst(11 downto 9) when if_id_inst(15 downto 12) = "0010" or -- SW
                                       if_id_inst(15 downto 12) = "0101" or -- BEQ
                                       if_id_inst(15 downto 12) = "0110"    -- BNE
               else if_id_inst(5 downto 3);

inst_Regs: registers port map (
    clk => clk_deb, reset => btn_reset, 
    reg_write => mem_wb_reg_write,
    rs1_addr => id_rs1_addr, rs2_addr => id_rs2_addr, rd_addr => mem_wb_rd_addr,
    write_data => wb_write_data, 
    rs1_data => id_rs1_data, rs2_data => id_rs2_data
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
    clk => clk_deb, reset => btn_reset, en => '1', flush => hz_id_ex_flush,
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

-- 3. EXECUTE (EX)
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
    clk => clk_deb, reset => btn_reset, en => '1', flush => '0',
    alu_result_in => ex_alu_result, rs2_data_in => alu_mux_b_out,
    rd_addr_in => id_ex_rd_addr, ctrl_mem_write_in => id_ex_mem_write,
    ctrl_reg_write_in => id_ex_reg_write, ctrl_mem_to_reg_in => id_ex_mem_to_reg,
    alu_result_out => ex_mem_alu_res, rs2_data_out => ex_mem_rs2_data,
    rd_addr_out => ex_mem_rd_addr, ctrl_mem_write_out => ex_mem_mem_write,
    ctrl_reg_write_out => ex_mem_reg_write, ctrl_mem_to_reg_out => ex_mem_mem_to_reg
);

btn_array <= ("000" & btn_sub & btn_add);

-- 4. MEMORY (MEM)
inst_Decoder: decoder port map (
    clk => clk_deb, reset => btn_reset,
    cpu_addr => ex_mem_alu_res, cpu_data_in => ex_mem_rs2_data, cpu_mem_write => ex_mem_mem_write,
    cpu_data_out => mem_dec_data_out, ram_data_out => mem_ram_data_out, ram_we => dec_ram_we,
    switches_in => swt, buttons_in => btn_array, 
    keypad_data_in => keypad_data,
    oled_data_out => oled_bus_out,
    leds_out => led, display_out => mmio_display_data
);

inst_7Seg: seven_seg_decoder port map (
    clk => clk, reset => btn_reset, data_in => mmio_display_data,
    seg => seg, dp => dp, an => an
);
--display_val <= if_reg_pc; -- Mostramos el PC para debug

inst_OLED: oled_spi_mmio port map (
    clk => clk_deb, -- Asegúrate de usar el mismo reloj con el que escribes (pipeline clk)
    reset => btn_reset,
    cpu_addr => ex_mem_alu_res,
    cpu_data_in => ex_mem_rs2_data,
    cpu_we => ex_mem_mem_write,
    cpu_data_out => oled_bus_out,
    oled_cs => oled_cs,
    oled_sdin => oled_sdin,
    oled_sclk => oled_sclk,
    oled_dc => oled_dc,
    oled_res => oled_res,
    oled_vbat => oled_vbat,
    oled_vdd => oled_vdd
);

inst_RAM: ram_data port map (
    clk => clk_deb, write_en => dec_ram_we, data_addr => ex_mem_alu_res, 
    data_in => ex_mem_rs2_data, data_out => mem_ram_data_out
);

--inst_LCD: entity work.lcd_controller
--    port map (
 --       clk        => clk,
 ---       reset      => btn_reset,
 --       char_in    => w_lcd_char_out,
 --       char_we    => w_lcd_char_we,
 --       cmd_in     => w_lcd_cmd_out,
 --       cmd_we     => w_lcd_cmd_we,
 --       busy       => w_lcd_busy,
  --      i2c_ena    => w_i2c_ena,
  --      i2c_data   => w_i2c_data,
 --       i2c_busy   => w_i2c_busy
 --   );

--inst_I2C: entity work.i2c_master
--    port map (
 --       clk        => clk,
 --       reset      => btn_reset,
 --       ena        => w_i2c_ena,
 --       addr       => "0100111", -- Dirección típica PCF8574 (ajusta si tu placa usa 0x3F u otra)
 --       rw         => '0',
 --       data_wr    => w_i2c_data,
 --       busy       => w_i2c_busy,
 --       sda        => lcd_sda,
  --      scl        => lcd_scl
  --  );

mem_cpu_data_in <= mem_dec_data_out;

reg_mem_wb: mem_wb_register port map (
    clk => clk_deb, reset => btn_reset, en => '1', flush => '0',
    alu_result_in => ex_mem_alu_res, ram_data_in => mem_cpu_data_in, rd_addr_in => ex_mem_rd_addr,
    ctrl_reg_write_in => ex_mem_reg_write, ctrl_mem_to_reg_in => ex_mem_mem_to_reg,
    alu_result_out => mem_wb_alu_res, ram_data_out => mem_wb_ram_data,
    rd_addr_out => mem_wb_rd_addr, ctrl_reg_write_out => mem_wb_reg_write,
    ctrl_mem_to_reg_out => mem_wb_mem_to_reg
);

-- 5. WRITEBACK (WB)
wb_write_data <= mem_wb_ram_data when mem_wb_mem_to_reg = '1' else mem_wb_alu_res;


end Structural;
