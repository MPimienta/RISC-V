----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/16/2026 04:38:51 PM
-- Design Name: 
-- Module Name: top_level - Structural
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_level is
    Port ( 
        clk         : in std_logic ;
        btn_clk     : in std_logic ;
        btn_reset   : in std_logic ;
        -- peripherals
        btn_add     : in std_logic ;
        btn_sub     : in std_logic ;
        swt         : in std_logic_vector (15 downto 0);
        led         : out std_logic_vector (15 downto 0);
        -- 7seg_display
        seg         : out std_logic_vector (6 downto 0);
        dp          : out std_logic;
        an          : out std_logic_vector (3 downto 0);
        -- pmod_keypad
        keypad_col  : in std_logic_vector(3 downto 0);
        keypad_row  : out std_logic_vector(3 downto 0);
        -- pmod_oled
        oled_cs     : out std_logic;
        oled_sdin   : out std_logic;
        oled_sclk   : out std_logic;
        oled_dc     : out std_logic;
        oled_res    : out std_logic;
        oled_vbat   : out std_logic;
        oled_vdd    : out std_logic
    );
end top_level;


architecture Structural of top_level is
    component freq_divider is
    Port ( clk_in : in STD_LOGIC;
           clk_out : out STD_LOGIC);
    end component;

    component riscv is
        Port (
            clk         : in std_logic ;
            reset       : in std_logic ;
            inst_addr   : out std_logic_vector (15 downto 0);
            instruction : in std_logic_vector (15 downto 0);
            write_en    : out std_logic;
            data_addr   : out std_logic_vector (15 downto 0);
            data_out    : out std_logic_vector (15 downto 0);
            data_in     : in  std_logic_vector (15 downto 0)
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
            oled_data_out : in std_logic
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
            clk, reset      : in std_logic;
            cpu_addr        : in std_logic_vector(15 downto 0);
            cpu_data_in     : in std_logic_vector(15 downto 0);
            cpu_we          : in std_logic;
            cpu_data_out    : out std_logic;
            oled_cs         : out std_logic ;
            oled_sdin       : out std_logic ;
            oled_sclk       : out std_logic ;
            oled_dc         : out std_logic ;
            oled_res        : out std_logic ;
            oled_vbat       : out std_logic ;
            oled_vdd        : out std_logic 
        );
    end component;
    
    signal sig_inst_addr : std_logic_vector(15 downto 0);
    signal sig_inst_data : std_logic_vector(15 downto 0);
    
    -- Buses de Datos (Memory / MMIO)
    signal sig_data_addr  : std_logic_vector(15 downto 0);
    signal sig_cpu_to_mem : std_logic_vector(15 downto 0); 
    signal sig_mem_to_cpu : std_logic_vector(15 downto 0); 
    signal sig_mem_write  : std_logic;
    
    -- Señales entre RAM y Decoder
    signal sig_ram_we       : std_logic;
    signal sig_ram_data_out : std_logic_vector(15 downto 0);
    
    -- Señales de Periféricos al Decoder
    signal sig_keypad_data : std_logic_vector(15 downto 0);
    signal sig_oled_data   : std_logic;
    signal sig_display_in  : std_logic_vector(15 downto 0);
    
    -- Señal auxiliar para botones
    signal sig_buttons_concat : std_logic_vector(4 downto 0);
    
    signal clk_div : std_logic := '0';



begin

    inst_freq_div: freq_divider
        Port map (
            clk_in  => clk,
            clk_out => clk_div
        );
    
    
    inst_cpu: riscv
        Port map (
            clk         => clk_div,
            reset       => btn_reset,
            inst_addr   => sig_inst_addr,
            instruction => sig_inst_data,
            data_addr   => sig_data_addr,   
            data_out    => sig_cpu_to_mem,  
            data_in     => sig_mem_to_cpu, 
            write_en    => sig_mem_write
        );

    inst_rom: rom_instructions
        Port map (
            instruction_addr => sig_inst_addr,
            instruction_out  => sig_inst_data
        );

    inst_decoder: decoder
        Port map (
            clk            => clk_div,
            reset          => btn_reset,
            cpu_addr       => sig_data_addr,
            cpu_data_in    => sig_cpu_to_mem,
            cpu_mem_write  => sig_mem_write,
            cpu_data_out   => sig_mem_to_cpu,
            ram_data_out   => sig_ram_data_out,
            ram_we         => sig_ram_we,
            switches_in    => swt,
            buttons_in     => sig_buttons_concat,
            keypad_data_in => sig_keypad_data,
            oled_data_out  => sig_oled_data,
            leds_out       => led,
            display_out    => sig_display_in
        );
        
    sig_buttons_concat <= "000" & btn_add & btn_sub;

    inst_ram: ram_data
        Port map (
            clk       => clk_div,
            write_en  => sig_ram_we,
            data_addr => sig_data_addr,
            data_in   => sig_cpu_to_mem,
            data_out  => sig_ram_data_out
        );

    inst_7seg: seven_seg_decoder
        Port map (
            clk     => clk_div,
            reset   => btn_reset,
            data_in => sig_display_in,
            seg     => seg,
            dp      => dp,
            an      => an
        );

    inst_keypad: keypad_controller
        Port map (
            clk        => clk_div,
            reset      => btn_reset,
            keypad_col => keypad_col,
            keypad_row => keypad_row,
            data_out   => sig_keypad_data
        );

    inst_oled_spi: oled_spi_mmio
        Port map (
            clk          => clk_div,
            reset        => btn_reset,
            cpu_addr     => sig_data_addr,
            cpu_data_in  => sig_cpu_to_mem,
            cpu_we       => sig_mem_write,
            cpu_data_out => sig_oled_data,
            oled_cs      => oled_cs,
            oled_sdin    => oled_sdin,
            oled_sclk    => oled_sclk,
            oled_dc      => oled_dc,
            oled_res     => oled_res,
            oled_vbat    => oled_vbat,
            oled_vdd     => oled_vdd
        );

end Structural;
