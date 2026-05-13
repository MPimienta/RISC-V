library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_level is
    Port ( 
        clk         : in std_logic;
        btn_reset   : in std_logic;
        btn_clk     : in std_logic;
        
        swt         : in std_logic_vector (15 downto 0);
        led         : out std_logic_vector (15 downto 0);
        seg         : out std_logic_vector (6 downto 0);
        dp          : out std_logic;
        an          : out std_logic_vector (3 downto 0);
        
        -- Pines físicos para el Teclado Matricial
        keypad_col  : in std_logic_vector(3 downto 0);
        keypad_row  : out std_logic_vector(3 downto 0);
        
        -- Pines físicos para la pantalla LCD I2C
        sda         : inout std_logic;
        scl         : inout std_logic
    );
end top_level;

architecture Structural of top_level is

    component riscv is
        Port ( 
            btn_clk     : in std_logic;
            clk         : in std_logic;
            btn_reset   : in std_logic;
            swt         : in std_logic_vector (15 downto 0); 
            led         : out std_logic_vector (15 downto 0); 
            seg         : out std_logic_vector (6 downto 0);
            dp          : out std_logic;
            an          : out std_logic_vector (3 downto 0);
            
            -- Teclado
            keypad_col  : in std_logic_vector(3 downto 0);
            keypad_row  : out std_logic_vector(3 downto 0);
            
            -- Cables chivatos para el LCD
            dbg_opcode  : out std_logic_vector (3 downto 0);
            dbg_reg     : out std_logic_vector (2 downto 0);
            dbg_val     : out std_logic_vector (15 downto 0)
        );
    end component;

    component display_subsystem is
        Port (
            clk         : in  std_logic;
            reset       : in  std_logic;
            cpu_opcode  : in  std_logic_vector(6 downto 0);
            cpu_reg     : in  std_logic_vector(4 downto 0);
            cpu_val     : in  std_logic_vector(15 downto 0);
            sda         : inout std_logic;
            scl         : inout std_logic
        );
    end component;

    -- Señales internas para sacar la info de la CPU
    signal w_dbg_opcode : std_logic_vector(3 downto 0);
    signal w_dbg_reg    : std_logic_vector(2 downto 0);
    signal w_dbg_val    : std_logic_vector(15 downto 0);

    -- Cables adaptadores con el tamaño final exacto
    signal w_opcode_padded : std_logic_vector(6 downto 0);
    signal w_reg_padded    : std_logic_vector(4 downto 0);

begin

    w_opcode_padded <= "000" & w_dbg_opcode;
    w_reg_padded    <= "00"  & w_dbg_reg;

    Inst_CPU: riscv port map (
        btn_clk     => btn_clk,
        clk         => clk,
        btn_reset   => btn_reset,
        swt         => swt,
        led         => led,
        seg         => seg,
        dp          => dp,
        an          => an,
        keypad_col  => keypad_col,
        keypad_row  => keypad_row,
        dbg_opcode  => w_dbg_opcode,
        dbg_reg     => w_dbg_reg,
        dbg_val     => w_dbg_val
    );

    Inst_Display: display_subsystem port map (
        clk         => clk, -- Reloj principal de 100MHz para el I2C
        reset       => btn_reset,
        cpu_opcode  => w_opcode_padded,
        cpu_reg     => w_reg_padded,
        cpu_val     => w_dbg_val,
        sda         => sda,
        scl         => scl
    );

end Structural;