library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity oled_spi_mmio is
    Port ( 
        clk           : in std_logic;
        reset         : in std_logic;
        cpu_addr      : in std_logic_vector(15 downto 0);
        cpu_data_in   : in std_logic_vector(15 downto 0);
        cpu_we        : in std_logic;
        cpu_data_out  : out std_logic;
        oled_cs       : out std_logic;
        oled_sdin     : out std_logic;
        oled_sclk     : out std_logic;
        oled_dc       : out std_logic;
        oled_res      : out std_logic;
        oled_vbat     : out std_logic;
        oled_vdd      : out std_logic
    );
end oled_spi_mmio;

architecture Behavioral of oled_spi_mmio is
    -- Registros MMIO
    signal ctrl_reg    : std_logic_vector(4 downto 0) := "00100"; 
    signal status_busy : std_logic := '0';
    type state_type is (IDLE, SHIFT_LOW, SHIFT_HIGH);
    signal state : state_type := IDLE;
    
    signal shift_reg   : std_logic_vector(7 downto 0) := (others => '0');
    signal bit_counter : integer range 0 to 7 := 0;
    constant MAX_COUNT : integer := 2; 
    signal clk_div     : integer range 0 to MAX_COUNT := 0;
    signal sclk_int    : std_logic := '0';

begin

    oled_dc   <= ctrl_reg(0);
    oled_res  <= ctrl_reg(1);
    oled_cs   <= ctrl_reg(2);
    oled_vdd  <= ctrl_reg(3);
    oled_vbat <= ctrl_reg(4);
    
    oled_sclk <= sclk_int;
    oled_sdin <= shift_reg(7); 

    process(cpu_addr, status_busy)
    begin
        cpu_data_out <= '0';
        if cpu_addr = x"FFF4" then
            cpu_data_out <= status_busy;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= IDLE;
                status_busy <= '0';
                sclk_int <= '0';
                ctrl_reg <= "00100";
                
            else
                if cpu_we = '1' then
                    if cpu_addr = x"FFF2" then
                        ctrl_reg <= cpu_data_in(4 downto 0);
                    elsif cpu_addr = x"FFF3" and status_busy = '0' then
                        shift_reg <= cpu_data_in(7 downto 0);
                        status_busy <= '1';
                        bit_counter <= 7;
                        state <= SHIFT_LOW;
                        clk_div <= 0;
                        sclk_int <= '0';
                    end if;
                end if;

                if status_busy = '1' then
                    if clk_div = MAX_COUNT then
                        clk_div <= 0;
                        
                        case state is
                            when SHIFT_LOW =>
                                sclk_int <= '1'; 
                                state <= SHIFT_HIGH;
                                
                            when SHIFT_HIGH =>
                                sclk_int <= '0';
                                if bit_counter = 0 then
                                    status_busy <= '0'; 
                                    state <= IDLE;
                                else
                                    shift_reg <= shift_reg(6 downto 0) & '0'; 
                                    bit_counter <= bit_counter - 1;
                                    state <= SHIFT_LOW;
                                end if;
                                
                            when IDLE =>
                                status_busy <= '0';
                        end case;
                    else
                        clk_div <= clk_div + 1;
                    end if;
                end if;
                
            end if;
        end if;
    end process;

end Behavioral;