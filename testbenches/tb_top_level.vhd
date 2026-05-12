library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_top_level is
end tb_top_level;

architecture Behavioral of tb_top_level is

    -- Declaración de nuestro componente principal (La Placa Base)
    component top_level
        Port ( 
            clk         : in std_logic;
            btn_reset   : in std_logic;
            btn_clk     : in std_logic;
            swt         : in std_logic_vector (15 downto 0);
            led         : out std_logic_vector (15 downto 0);
            seg         : out std_logic_vector (6 downto 0);
            dp          : out std_logic;
            an          : out std_logic_vector (3 downto 0);
            sda         : inout std_logic;
            scl         : inout std_logic
        );
    end component;

    -- Entradas
    signal clk       : std_logic := '0';
    signal btn_reset : std_logic := '0';
    signal btn_clk   : std_logic := '0';
    signal swt       : std_logic_vector(15 downto 0) := (others => '0');

    -- Salidas
    signal led       : std_logic_vector(15 downto 0);
    signal seg       : std_logic_vector(6 downto 0);
    signal dp        : std_logic;
    signal an        : std_logic_vector(3 downto 0);
    
    -- Bus I2C
    signal sda       : std_logic;
    signal scl       : std_logic;

    -- Periodo del reloj principal (100 MHz de la placa)
    constant clk_period : time := 10 ns;

begin

    -- Simulamos las resistencias Pull-Up de la placa física para el bus I2C
    -- 'H' significa "1 lógico débil". El Master I2C podrá forzarlo a '0' cuando transmita.
    sda <= 'H';
    scl <= 'H';

    -- Instanciación del sistema completo
    uut: top_level Port map (
        clk         => clk,
        btn_reset   => btn_reset,
        btn_clk     => btn_clk,
        swt         => swt,
        led         => led,
        seg         => seg,
        dp          => dp,
        an          => an,
        sda         => sda,
        scl         => scl
    );

    -- Generador del reloj continuo de 100 MHz
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Proceso de estímulos (El "dedo" que pulsa los botones)
    stim_proc: process
    begin
        -- 1. Secuencia de Reset inicial
        btn_reset <= '1';
        wait for 100 ns;
        btn_reset <= '0';
        wait for 100 ns;

        -- 2. Damos suficientes pulsaciones manuales para ver el envío I2C.
        -- NOTA: El I2C es LENTÍSIMO comparado con la CPU. Haremos bastantes ciclos.
        for i in 1 to 200 loop
            btn_clk <= '1';
            wait for 200 ns; 
            btn_clk <= '0';
            wait for 200 ns;
        end loop;

        -- Dejamos que el reloj interno de 100MHz procese la transmisión de la pantalla
        wait for 100 ms; 

        -- Fin de la simulación
        wait;
    end process;

end Behavioral;