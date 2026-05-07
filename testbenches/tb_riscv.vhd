library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity riscv_tb is
end riscv_tb;

architecture behavior of riscv_tb is

    -- Declaración del componente Top Module actualizado a 16 bits
    component riscv
        Port ( 
            btn_clk     : in std_logic;
            clk         : in std_logic;
            btn_reset   : in std_logic;
            swt         : in std_logic_vector (15 downto 0);
            led         : out std_logic_vector (15 downto 0);
            seg         : out std_logic_vector (6 downto 0);
            dp          : out std_logic;
            an          : out std_logic_vector (3 downto 0)
        );
    end component;

    -- Entradas
    signal btn_clk   : std_logic := '0';
    signal clk       : std_logic := '0';
    signal btn_reset : std_logic := '0';
    signal swt       : std_logic_vector(15 downto 0) := (others => '0');

    -- Salidas
    signal led       : std_logic_vector(15 downto 0);
    signal seg       : std_logic_vector(6 downto 0);
    signal dp        : std_logic;
    signal an        : std_logic_vector(3 downto 0);

    -- Periodo del reloj principal (100 MHz de la placa)
    constant clk_period : time := 10 ns;

begin

    -- Instanciación del procesador
    uut: riscv Port map (
        btn_clk   => btn_clk,
        clk       => clk,
        btn_reset => btn_reset,
        swt       => swt,
        led       => led,
        seg       => seg,
        dp        => dp,
        an        => an
    );

    -- Proceso generador del reloj de 100 MHz
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Proceso de estímulos (El "dedo" que pulsa el botón)
    stim_proc: process
    begin
        -- 1. Secuencia de Reset inicial
        btn_reset <= '1';
        wait for 100 ns;
        btn_reset <= '0';
        wait for 100 ns;

        -- Dejamos los switches a 0 (no se usan en este programa, pero es buena práctica)
        swt <= x"0000";

        -- 2. Damos 120 pulsaciones de reloj manual.
        -- Cada instrucción ahora tarda exactamente 3 ciclos de FSM (FETCH -> DECODE -> EXEC/MEM/JUMP)
        -- Con 120 pulsos, ejecutaremos unas 40 instrucciones (da para unas 5 vueltas completas al bucle).
        for i in 1 to 120 loop
            btn_clk <= '1';
            wait for 200 ns; 
            btn_clk <= '0';
            wait for 200 ns;
        end loop;

        -- Fin de la simulación
        wait;
    end process;

end behavior;