library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity riscv is
    Port ( 
        btn_clk     : in std_logic;
        clk         : in std_logic;
        btn_reset   : in std_logic;
        swt         : in std_logic_vector (15 downto 0); -- AHORA 16 BITS (Toda la Basys 3)
        led         : out std_logic_vector (15 downto 0); -- AHORA 16 BITS (Toda la Basys 3)
        seg         : out std_logic_vector (6 downto 0);
        dp          : out std_logic;
        an          : out std_logic_vector (3 downto 0);
        sda         : inout std_logic;
        scl         : inout std_logic
        );
end riscv;

architecture Structural of riscv is

component registers is
    Port(
        clk         :   in std_logic ;
        reset       :   in std_logic ;
        reg_write   :   in std_logic ;                      
        rs1_addr    :   in std_logic_vector (2 downto 0);   
        rs2_addr    :   in std_logic_vector (2 downto 0);   
        rd_addr     :   in std_logic_vector (2 downto 0);   
        write_data  :   in std_logic_vector (15 downto 0);   
        rs1_data    :   out std_logic_vector (15 downto 0);  
        rs2_data    :   out std_logic_vector (15 downto 0)    
    );
end component;

component ALU is
    Port ( 
            A       :   in  std_logic_vector (15 downto 0); 
            B       :   in  std_logic_vector (15 downto 0); 
            ALU_Sel :   in  std_logic_vector (2 downto 0); 
            Result  :   out std_logic_vector (15 downto 0);
            Zero    :   out std_logic 
            );
end component;

component branch_adder is
    Port ( pc_in : in STD_LOGIC_VECTOR (15 downto 0);
           imm_in : in STD_LOGIC_VECTOR (15 downto 0);
           target_out : out STD_LOGIC_VECTOR (15 downto 0));
end component;

component control_unit is
    Port (
        clk : in std_logic;
        reset : in std_logic;
        opcode : in std_logic_vector(3 downto 0);
        funct : in std_logic_vector(2 downto 0);
        zero : in std_logic;
        
        pc_en : out std_logic;
        pc_load : out std_logic;
        reg_write : out std_logic;
        alu_sel : out std_logic_vector(2 downto 0);
        alu_src_b : out std_logic;
        mem_write  : out std_logic;
        mem_to_reg : out std_logic;
        ir_en : out std_logic -- ACTUALIZADO
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
        clk          : in std_logic;
        reset        : in std_logic;
        cpu_addr     : in std_logic_vector(15 downto 0);
        cpu_data_in  : in std_logic_vector(15 downto 0); 
        cpu_mem_write: in std_logic;
        cpu_data_out : out std_logic_vector(15 downto 0);
        ram_data_out : in std_logic_vector(15 downto 0); 
        ram_we       : out std_logic;
        switches_in  : in std_logic_vector(15 downto 0);
        buttons_in   : in std_logic_vector(4 downto 0); -- ACTUALIZADO A 5 BITS
        leds_out     : out std_logic_vector(15 downto 0);
        display_out  : out std_logic_vector(15 downto 0);
        lcd_we_out   : out std_logic
    );
end component;

component immediate_gen is
    Port ( instruction   : in STD_LOGIC_VECTOR (15 downto 0);
           immediate_out : out STD_LOGIC_VECTOR (15 downto 0));
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
        write_en        :   in std_logic ;
        data_in         :   in std_logic_vector (15 downto 0);
        data_out        :   out std_logic_vector (15 downto 0);
        data_addr       :   in std_logic_vector (15 downto 0);
        clk             :   in std_logic 
    );
end component;

component rom_instructions is
    Port (
        instruction_out     :   out std_logic_vector(15 downto 0);
        instruction_addr    :   in std_logic_vector (15 downto 0)   
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

component i2c_master is
    Generic (
        input_clk : integer := 100_000_000;
        bus_clk   : integer := 100_000
    );
    Port (
        clk       : in     std_logic;
        reset     : in     std_logic;
        ena       : in     std_logic;
        addr      : in     std_logic_vector(6 downto 0);
        rw        : in     std_logic;
        data_wr   : in     std_logic_vector(7 downto 0);
        busy      : out    std_logic;
        ack_error : out    std_logic;
        sda       : inout  std_logic;
        scl       : inout  std_logic
    );
end component;
    
component lcd_controller is
    Port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        lcd_we   : in  std_logic;
        data_in  : in  std_logic_vector(15 downto 0);
        i2c_ena  : out std_logic;
        i2c_data : out std_logic_vector(7 downto 0);
        i2c_busy : in  std_logic;
        i2c_addr : out std_logic_vector(6 downto 0)
    );
end component;  

    -- SEÑALES INTERNAS (TODAS A 16 BITS)
    signal clk_deb       : std_logic; 
    signal pc_current    : std_logic_vector(15 downto 0); 
    signal pc_next       : std_logic_vector(15 downto 0); 
    signal branch_target : std_logic_vector(15 downto 0); 
    signal pc_en_sig     : std_logic;                    
    signal pc_load_sig   : std_logic;                    

    signal rom_data_raw  : std_logic_vector(15 downto 0);  
    signal ir_register   : std_logic_vector(15 downto 0); -- REGISTRO ÚNICO 16 BITS
    signal ctrl_ir_en    : std_logic;                    

    signal ctrl_reg_write : std_logic;
    signal ctrl_alu_sel   : std_logic_vector(2 downto 0);
    signal ctrl_alu_src_b : std_logic;
    signal ctrl_mem_write : std_logic;
    signal ctrl_mem_to_reg: std_logic;

    signal reg_rs1_data  : std_logic_vector(15 downto 0);
    signal reg_rs2_data  : std_logic_vector(15 downto 0);
    signal reg_write_data: std_logic_vector(15 downto 0); 
    
    signal alu_operand_b : std_logic_vector(15 downto 0); 
    signal alu_res_out   : std_logic_vector(15 downto 0);
    signal alu_zero_flag : std_logic;
    
    signal imm_ext_out   : std_logic_vector(15 downto 0); 

    signal mem_cpu_data_out : std_logic_vector(15 downto 0); 
    signal ram_data_raw     : std_logic_vector(15 downto 0); 
    signal dec_ram_we       : std_logic;                    
    signal display_val      : std_logic_vector(15 downto 0); 

    signal w_rs2_addr : std_logic_vector(2 downto 0);
    
    signal dec_lcd_we  : std_logic;
    signal w_i2c_ena   : std_logic;
    signal w_i2c_data  : std_logic_vector(7 downto 0);
    signal w_i2c_busy  : std_logic;
    signal w_i2c_addr  : std_logic_vector(6 downto 0);
begin

    deb_clk: debouncer port map (clk => clk, reset => btn_reset, btn_in => btn_clk, btn_out => clk_deb);
    
    inst_PC: program_counter port map (clk => clk_deb, reset => btn_reset, pc_en => pc_en_sig, load => pc_load_sig, d_in => pc_next, pc_out => pc_current);
    
    inst_ROM: rom_instructions port map (instruction_addr => pc_current, instruction_out => rom_data_raw);
    
    inst_I2C: i2c_master
        generic map (
            input_clk => 100000000, -- 100MHz de la Basys 3
            bus_clk   => 100000     -- 100kHz estándar para I2C
        )
        port map (
            clk       => clk,
            reset     => btn_reset,
            ena       => w_i2c_ena,
            addr      => w_i2c_addr,
            rw        => '0',         -- Siempre escribimos en la LCD
            data_wr   => w_i2c_data,
            busy      => w_i2c_busy,
            ack_error => open,        -- Podemos dejarlo abierto por ahora
            sda       => sda,         -- Pin físico directo al puerto PMOD
            scl       => scl          -- Pin físico directo al puerto PMOD
        );
        
    inst_LCD: lcd_controller
        port map (
            clk      => clk,
            reset    => btn_reset,
            lcd_we   => dec_lcd_we,   -- Viene de la lógica del Decoder
            data_in  => reg_rs2_data, -- El valor que queremos mostrar (normalmente R2 o R1)
            i2c_ena  => w_i2c_ena,
            i2c_data => w_i2c_data,
            i2c_busy => w_i2c_busy,
            i2c_addr => w_i2c_addr
        );
        
    -- REGISTRO DE INSTRUCCIÓN (1 CICLO)
    process(clk_deb)
    begin
        if rising_edge(clk_deb) then
            if btn_reset = '1' then
                ir_register <= (others => '0');
            elsif ctrl_ir_en = '1' then
                ir_register <= rom_data_raw; 
            end if;
        end if;
    end process;

    inst_CU: control_unit port map (
        clk => clk_deb, reset => btn_reset, zero => alu_zero_flag,
        opcode => ir_register(15 downto 12), funct => ir_register(2 downto 0),
        pc_en => pc_en_sig, pc_load => pc_load_sig, reg_write => ctrl_reg_write,
        alu_sel => ctrl_alu_sel, alu_src_b => ctrl_alu_src_b, 
        mem_write => ctrl_mem_write, mem_to_reg => ctrl_mem_to_reg,
        ir_en => ctrl_ir_en
    );

    inst_ImmGen: immediate_gen port map (
        instruction => ir_register,
        immediate_out => imm_ext_out
    );
    
    w_rs2_addr <= ir_register(11 downto 9) when ir_register(15 downto 12) = "0010" else -- SW
                  ir_register(11 downto 9) when ir_register(15 downto 12) = "0101" else -- BEQ
                  ir_register(11 downto 9) when ir_register(15 downto 12) = "0110" else -- BNE
                  ir_register(5 downto 3);

    inst_Regs: registers port map (
        clk => clk_deb, reset => btn_reset, reg_write => ctrl_reg_write,
        rs1_addr => ir_register(8 downto 6), 
        rs2_addr => w_rs2_addr,
        rd_addr => ir_register(11 downto 9),
        write_data => reg_write_data, rs1_data => reg_rs1_data, rs2_data => reg_rs2_data
    );

    alu_operand_b <= reg_rs2_data when ctrl_alu_src_b = '0' else imm_ext_out;
    inst_ALU: ALU port map (A => reg_rs1_data, B => alu_operand_b, ALU_Sel => ctrl_alu_sel, Result => alu_res_out, Zero => alu_zero_flag);

    inst_Decoder: decoder port map (
        clk           => clk_deb,
        reset         => btn_reset,
        cpu_addr      => alu_res_out,
        cpu_data_in   => reg_rs2_data,
        cpu_mem_write => ctrl_mem_write,
        cpu_data_out  => mem_cpu_data_out,
        ram_data_out  => ram_data_raw,
        ram_we        => dec_ram_we,
        switches_in   => swt,
        buttons_in    => "00000", -- Simulamos que no se pulsan botones de momento
        leds_out      => led,        
        display_out   => display_val,
        lcd_we_out        => dec_lcd_we
    );

    inst_RAM: ram_data port map (clk => clk_deb, write_en => dec_ram_we, data_addr => alu_res_out, data_in => reg_rs2_data, data_out => ram_data_raw);

    reg_write_data <= alu_res_out when ctrl_mem_to_reg = '0' else mem_cpu_data_out;

    inst_Branch: branch_adder port map (pc_in => pc_current, imm_in => imm_ext_out, target_out => branch_target);
            
    pc_next <= alu_res_out when ir_register(15 downto 12) = "1000" else branch_target; -- Opcode 1000 es JALR
   
   inst_Seg7: seven_seg_decoder port map (
        clk      => clk,         
        reset    => btn_reset,
        data_in  => pc_current, 
        seg      => seg,         
        dp       => dp,
        an       => an
    );
    
end Structural;