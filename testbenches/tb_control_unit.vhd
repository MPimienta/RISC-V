library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_control_unit is
end tb_control_unit;

architecture Behavioral of tb_control_unit is

    component control_unit
        Port (
            clk : in std_logic;
            reset : in std_logic;
            opcode : in std_logic_vector(7 downto 0);
            zero : in std_logic;
            pc_en : out std_logic;
            pc_load : out std_logic;
            reg_write : out std_logic;
            alu_sel : out std_logic_vector(2 downto 0);
            ir_en : out std_logic
        );
    end component;

    signal clk_tb : std_logic := '0';
    signal reset_tb : std_logic := '0';
    signal opcode_tb : std_logic_vector(7 downto 0) := (others => '0');
    signal zero_tb : std_logic := '0';
    
    signal pc_en_tb : std_logic;
    signal pc_load_tb : std_logic;
    signal reg_write_tb : std_logic;
    signal alu_sel_tb : std_logic_vector(2 downto 0);
    signal ir_en_tb : std_logic;

    constant clk_period : time := 10 ns;

begin

    uut: control_unit port map (
        clk  => clk_tb,
        reset => reset_tb,
        opcode => opcode_tb,
        zero => zero_tb,
        pc_en => pc_en_tb,
        pc_load => pc_load_tb,
        reg_write => reg_write_tb,
        alu_sel => alu_sel_tb,
        ir_en => ir_en_tb
    );

    clk_process : process
    begin
        clk_tb <= '0';
        wait for clk_period/2;
        clk_tb <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
    begin		
        reset_tb <= '1';
        wait for 20 ns;
        reset_tb <= '0';
        wait for clk_period;

        -- ADD
        -- FETCH
        opcode_tb <= X"01"; 
        wait for clk_period; -- Aquí ir_en debe ser '1' y pc_en '1'
        
        -- DECODE
        wait for clk_period;
        
        -- EXECUTE (Debería poner alu_sel a "000") 
        wait for clk_period;
        
        -- WRITEBACK (Debería poner reg_write a '1') 
        wait for clk_period;
        
        -- BEQ con Salto
        -- FETCH
        opcode_tb <= X"08";
        zero_tb <= '1';
        wait for clk_period;
        
        -- DECODE
        wait for clk_period;
        
        -- JUMP (Debería activar pc_load)
        wait for clk_period;
        
        -- XOR
        -- FETCH
        opcode_tb <= X"07";
        wait for clk_period;

        -- DECODE
        wait for clk_period;

        -- EXECUTE: alu_sel debería ser "110"
        wait for clk_period;

         -- WRITEBACK: reg_write = '1'
        wait for clk_period;

        wait;
    end process;

end Behavioral;
