library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity oled_spi_mmio is
    Port ( 
        clk           : in std_logic;
        reset         : in std_logic;
        
        -- Interfaz con el bus de la CPU
        cpu_addr      : in std_logic_vector(15 downto 0);
        cpu_data_in   : in std_logic_vector(15 downto 0);
        cpu_we        : in std_logic;
        cpu_data_out  : out std_logic_vector(15 downto 0);
        
        -- Pines físicos hacia la PmodOLED
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
    signal ctrl_reg    : std_logic_vector(4 downto 0) := "00100"; -- CS alto por defecto
    signal status_busy : std_logic := '0';

    -- Máquina de estados SPI
    type state_type is (IDLE, SHIFT_LOW, SHIFT_HIGH);
    signal state : state_type := IDLE;
    
    signal shift_reg   : std_logic_vector(7 downto 0) := (others => '0');
    signal bit_counter : integer range 0 to 7 := 0;
    
    -- Divisor de reloj para SPI (Ajusta MAX_COUNT según tu clk principal)
    constant MAX_COUNT : integer := 2; -- Para 100MHz / (2 * 2) = ~25MHz máximo teórico, SSD1306 soporta hasta 10MHz, si usas 100MHz ponlo en 4.
    signal clk_div     : integer range 0 to MAX_COUNT := 0;
    signal sclk_int    : std_logic := '0';

begin

    -- Conexión de pines estáticos
    oled_dc   <= ctrl_reg(0);
    oled_res  <= ctrl_reg(1);
    oled_cs   <= ctrl_reg(2);
    oled_vdd  <= ctrl_reg(3);
    oled_vbat <= ctrl_reg(4);
    
    oled_sclk <= sclk_int;
    oled_sdin <= shift_reg(7); -- MOSI siempre saca el bit más significativo

    -- Proceso de Lectura del Bus (Asíncrono para el decodificador)
    process(cpu_addr, status_busy)
    begin
        cpu_data_out <= (others => '0');
        if cpu_addr = x"FFF4" then
            cpu_data_out(0) <= status_busy;
        end if;
    end process;

    -- Máquina de estados y Escritura
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= IDLE;
                status_busy <= '0';
                sclk_int <= '0';
                ctrl_reg <= "00100"; -- CS=1, Reset=0, todo apagado
                
            else
                -- 1. Escritura desde la CPU
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

                -- 2. Máquina de Estados de Transmisión SPI
                if status_busy = '1' then
                    if clk_div = MAX_COUNT then
                        clk_div <= 0;
                        
                        case state is
                            when SHIFT_LOW =>
                                sclk_int <= '1'; -- Flanco de subida (El esclavo lee aquí)
                                state <= SHIFT_HIGH;
                                
                            when SHIFT_HIGH =>
                                sclk_int <= '0'; -- Flanco de bajada
                                if bit_counter = 0 then
                                    status_busy <= '0'; -- Transmisión terminada
                                    state <= IDLE;
                                else
                                    shift_reg <= shift_reg(6 downto 0) & '0'; -- Desplazar
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