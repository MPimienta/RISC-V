library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity display_subsystem is
    Port (
        clk         : in    std_logic;
        reset       : in    std_logic;
        
        -- Entradas desde el procesador RISC-V
        cpu_opcode  : in  std_logic_vector(6 downto 0);
        cpu_reg     : in  std_logic_vector(4 downto 0);
        cpu_val     : in  std_logic_vector(15 downto 0);
        
        -- Salidas físicas hacia la pantalla LCD
        sda         : inout std_logic;
        scl         : inout std_logic
    );
end display_subsystem;

architecture Structural of display_subsystem is

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

    component lcd_controller
        Generic ( clk_freq : integer := 100_000_000 );
        Port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        char_in     : in  std_logic_vector(7 downto 0);
        char_we     : in  std_logic;
        cmd_in      : in  std_logic_vector(7 downto 0);
        cmd_we      : in  std_logic;
        busy        : out std_logic;
        i2c_ena     : out std_logic;
        i2c_data    : out std_logic_vector(7 downto 0);
        i2c_busy    : in  std_logic
        );
    end component;

    component i2c_master
        Port (
            clk         : in    std_logic;
            reset       : in    std_logic;
            ena         : in    std_logic;
            addr        : in    std_logic_vector(6 downto 0);
            rw          : in    std_logic;
            data_wr     : in    std_logic_vector(7 downto 0);
            busy        : out   std_logic;
            sda         : inout std_logic;
            scl         : inout std_logic
        );
    end component;

    -- Manager <-> Driver
    signal w_char_data   : std_logic_vector(7 downto 0);
    signal w_char_we     : std_logic;
    signal w_cmd_data    : std_logic_vector(7 downto 0);
    signal w_cmd_we      : std_logic;
    signal w_lcd_busy    : std_logic;

    -- Driver <-> I2C Master
    signal w_i2c_ena     : std_logic;
    signal w_i2c_data    : std_logic_vector(7 downto 0);
    signal w_i2c_busy    : std_logic;

begin

    Inst_Display_Mgr: display_manager port map (
        clk         => clk,
        reset       => reset,
        cpu_opcode  => cpu_opcode,
        cpu_reg     => cpu_reg,
        cpu_val     => cpu_val,
        lcd_busy    => w_lcd_busy,
        char_out    => w_char_data,
        char_we     => w_char_we,
        cmd_out     => w_cmd_data,
        cmd_we      => w_cmd_we
    );

    Inst_LCD_Controller: lcd_controller port map (
        clk         => clk,
        reset       => reset,
        char_in     => w_char_data,
        char_we     => w_char_we,
        cmd_in      => w_cmd_data,
        cmd_we      => w_cmd_we,
        busy        => w_lcd_busy,
        i2c_ena     => w_i2c_ena,
        i2c_data    => w_i2c_data,
        i2c_busy    => w_i2c_busy
    );

    Inst_I2C_Master: i2c_master port map (
        clk         => clk,
        reset       => reset,
        ena         => w_i2c_ena,
        addr        => "0100111",
        rw          => '0', -- Escritura siempre ('0')
        data_wr     => w_i2c_data,
        busy        => w_i2c_busy,
        sda         => sda,
        scl         => scl
    );

end Structural;