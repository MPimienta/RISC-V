library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_level is
    Port (
        -- Estos son los PINES FÍSICOS de tu placa FPGA
        clk         : in    std_logic;
        reset       : in    std_logic; -- Puede ser un botón físico
        
        -- Pines físicos para la pantalla I2C
        sda         : inout std_logic;
        scl         : inout std_logic
    );
end top_level;

architecture Behavioral of top_level is

    -- =========================================================
    -- 1. DECLARACIÓN DE COMPONENTES (Las piezas de nuestro puzle)
    -- =========================================================

    -- Tu procesador RISC-V
    component riscv
        Port (
            clk         : in  std_logic;
            reset       : in  std_logic;
            -- Señales que "salen" de tu CPU para que las lea el display
            out_opcode  : out std_logic_vector(6 downto 0);
            out_reg     : out std_logic_vector(4 downto 0);
            out_val     : out std_logic_vector(15 downto 0)
        );
    end component;

    -- El "Cerebro" de la pantalla que acabamos de hacer
    component display_manager
        Port (
            clk         : in  std_logic;
            reset       : in  std_logic;
            cpu_opcode  : in  std_logic_vector(6 downto 0);
            cpu_reg     : in  std_logic_vector(4 downto 0);
            cpu_val     : in  std_logic_vector(15 downto 0);
            lcd_busy    : in  std_logic;
            char_out    : out std_logic_vector(7 downto 0);
            char_we     : out std_logic;
            cmd_out     : out std_logic_vector(7 downto 0);
            cmd_we      : out std_logic
        );
    end component;

    -- El controlador del LCD (Asumiendo sus puertos generales)
    component lcd_driver_i2c
        Port (
            clk         : in  std_logic;
            reset       : in  std_logic;
            char_in     : in  std_logic_vector(7 downto 0);
            char_we     : in  std_logic;
            cmd_in      : in  std_logic_vector(7 downto 0);
            cmd_we      : in  std_logic;
            lcd_busy    : out std_logic;
            
            -- Interfaz hacia el master I2C
            i2c_ena     : out std_logic;
            i2c_addr    : out std_logic_vector(6 downto 0);
            i2c_data_wr : out std_logic_vector(7 downto 0);
            i2c_busy    : in  std_logic
        );
    end component;

    -- El master de I2C que habla con los pines físicos
    component i2c_master
        Port (
            clk         : in    std_logic;
            reset       : in    std_logic;
            ena         : in    std_logic;
            addr        : in    std_logic_vector(6 downto 0);
            rw          : in    std_logic; -- '0' para escribir
            data_wr     : in    std_logic_vector(7 downto 0);
            busy        : out   std_logic;
            sda         : inout std_logic;
            scl         : inout std_logic
        );
    end component;

    -- =========================================================
    -- 2. CABLES INTERNOS (Señales para conectar los bloques)
    -- =========================================================
    
    -- Cables CPU -> Display Manager
    signal w_cpu_opcode  : std_logic_vector(6 downto 0);
    signal w_cpu_reg     : std_logic_vector(4 downto 0);
    signal w_cpu_val     : std_logic_vector(15 downto 0);

    -- Cables Display Manager -> LCD Driver
    signal w_char_data   : std_logic_vector(7 downto 0);
    signal w_char_we     : std_logic;
    signal w_cmd_data    : std_logic_vector(7 downto 0);
    signal w_cmd_we      : std_logic;
    signal w_lcd_busy    : std_logic;

    -- Cables LCD Driver -> I2C Master
    signal w_i2c_ena     : std_logic;
    signal w_i2c_addr    : std_logic_vector(6 downto 0);
    signal w_i2c_data_wr : std_logic_vector(7 downto 0);
    signal w_i2c_busy    : std_logic;

begin

    -- =========================================================
    -- 3. INSTANCIACIÓN (Conectando los cables a las piezas)
    -- =========================================================

    -- Instancia 1: El procesador RISC-V
    Inst_CPU: riscv port map (
        clk         => clk,
        reset       => reset,
        out_opcode  => w_cpu_opcode,
        out_reg     => w_cpu_reg,
        out_val     => w_cpu_val
    );

    -- Instancia 2: El Display Manager
    Inst_Display_Mgr: display_manager port map (
        clk         => clk,
        reset       => reset,
        cpu_opcode  => w_cpu_opcode,
        cpu_reg     => w_cpu_reg,
        cpu_val     => w_cpu_val,
        lcd_busy    => w_lcd_busy,
        char_out    => w_char_data,
        char_we     => w_char_we,
        cmd_out     => w_cmd_data,
        cmd_we      => w_cmd_we
    );

    -- Instancia 3: El LCD Driver
    Inst_LCD_Driver: lcd_driver_i2c port map (
        clk         => clk,
        reset       => reset,
        char_in     => w_char_data,
        char_we     => w_char_we,
        cmd_in      => w_cmd_data,
        cmd_we      => w_cmd_we,
        lcd_busy    => w_lcd_busy,
        
        i2c_ena     => w_i2c_ena,
        i2c_addr    => w_i2c_addr,
        i2c_data_wr => w_i2c_data_wr,
        i2c_busy    => w_i2c_busy
    );

    -- Instancia 4: El Master I2C
    Inst_I2C_Master: i2c_master port map (
        clk         => clk,
        reset       => reset,
        ena         => w_i2c_ena,
        addr        => w_i2c_addr,
        rw          => '0', -- El LCD siempre es escritura
        data_wr     => w_i2c_data_wr,
        busy        => w_i2c_busy,
        sda         => sda, -- Directo al pin físico
        scl         => scl  -- Directo al pin físico
    );

end Behavioral;