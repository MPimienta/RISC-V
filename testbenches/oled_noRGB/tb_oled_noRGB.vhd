library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_oled_spi_mmio is
-- Un testbench no tiene puertos
end tb_oled_spi_mmio;

architecture behavior of tb_oled_spi_mmio is

    -- Declaración del componente a probar (DUT - Device Under Test)
    component oled_spi_mmio
    Port ( 
        clk           : in std_logic;
        reset         : in std_logic;
        cpu_addr      : in std_logic_vector(15 downto 0);
        cpu_data_in   : in std_logic_vector(15 downto 0);
        cpu_we        : in std_logic;
        cpu_data_out  : out std_logic_vector(15 downto 0);
        oled_cs       : out std_logic;
        oled_sdin     : out std_logic;
        oled_sclk     : out std_logic;
        oled_dc       : out std_logic;
        oled_res      : out std_logic;
        oled_vbat     : out std_logic;
        oled_vdd      : out std_logic
    );
    end component;

    -- Señales internas para conectar con el DUT
    signal clk          : std_logic := '0';
    signal reset        : std_logic := '1';
    signal cpu_addr     : std_logic_vector(15 downto 0) := (others => '0');
    signal cpu_data_in  : std_logic_vector(15 downto 0) := (others => '0');
    signal cpu_we       : std_logic := '0';
    signal cpu_data_out : std_logic_vector(15 downto 0);
    
    signal oled_cs      : std_logic;
    signal oled_sdin    : std_logic;
    signal oled_sclk    : std_logic;
    signal oled_dc      : std_logic;
    signal oled_res     : std_logic;
    signal oled_vbat    : std_logic;
    signal oled_vdd     : std_logic;

    -- Definición del periodo de reloj (Simulando 100 MHz)
    constant clk_period : time := 10 ns;

begin

    -- Instanciación del módulo
    uut: oled_spi_mmio port map (
        clk => clk,
        reset => reset,
        cpu_addr => cpu_addr,
        cpu_data_in => cpu_data_in,
        cpu_we => cpu_we,
        cpu_data_out => cpu_data_out,
        oled_cs => oled_cs,
        oled_sdin => oled_sdin,
        oled_sclk => oled_sclk,
        oled_dc => oled_dc,
        oled_res => oled_res,
        oled_vbat => oled_vbat,
        oled_vdd => oled_vdd
    );

    -- Generador de Reloj
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Proceso de estímulos (El "Programa" de prueba)
    stim_proc: process
    begin		
        -- 1. Estado inicial y Reset
        reset <= '1';
        wait for 50 ns;
        reset <= '0';
        wait for 50 ns;

        -- 2. Simular CPU: Escribir en Registro de Control (0x00F2)
        -- Queremos: CS=0 (activo), Reset=1 (inactivo), VDD=1, VBAT=1, D/C=0 (Comando)
        -- Bit 4: Vbat(1), Bit 3: Vdd(1), Bit 2: CS(0), Bit 1: Res(1), Bit 0: D/C(0) -> 11010 en binario = 0x001A
        wait until rising_edge(clk);
        cpu_addr <= x"FFF2";
        cpu_data_in <= x"001A";
        cpu_we <= '1';
        
        wait until rising_edge(clk);
        cpu_we <= '0'; -- Bajamos el Write Enable
        wait for 50 ns;

        -- 3. Simular CPU: Enviar un byte por SPI (Registro de Datos 0x00F3)
        -- Vamos a enviar el comando 0xAF (Display ON)
        wait until rising_edge(clk);
        cpu_addr <= x"FFF3";
        cpu_data_in <= x"00AF"; -- 1010 1111
        cpu_we <= '1';
        
        wait until rising_edge(clk);
        cpu_we <= '0';
        
        -- 4. Simular CPU: Leer el estado (Polling) hasta que termine
        -- La CPU se quedaría leyendo la dirección 0x00F4 esperando un 0 en el Bit 0
        cpu_addr <= x"FFF4";
        loop
            wait until rising_edge(clk);
            exit when cpu_data_out(0) = '0'; -- Salir del bucle si busy = 0
        end loop;
        
        wait for 100 ns;

        -- 5. Simular CPU: Enviar un segundo byte (Ej. 0x55 -> 0101 0101)
        wait until rising_edge(clk);
        cpu_addr <= x"FFF3";
        cpu_data_in <= x"0055"; 
        cpu_we <= '1';
        
        wait until rising_edge(clk);
        cpu_we <= '0';

        -- Esperar un buen rato para ver toda la onda en el simulador
        wait for 5000 ns;
        
        -- Detener la simulación
        assert false report "Fin de la simulacion" severity failure;
    end process;

end behavior;