library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity riscv_tb is
end riscv_tb;

architecture behavior of riscv_tb is

    component riscv
        Port ( 
            btn_clk     : in std_logic;
            clk         : in std_logic;
            btn_reset   : in std_logic;
            swt         : in std_logic_vector (7 downto 0);
            led         : out std_logic_vector (7 downto 0);
            seg         : out std_logic_vector (6 downto 0);
            dp          : out std_logic;
            an          : out std_logic_vector (3 downto 0)
        );
    end component;

    signal btn_clk   : std_logic := '0';
    signal clk       : std_logic := '0';
    signal btn_reset : std_logic := '0';
    signal swt       : std_logic_vector (7 downto 0) := (others => '0');
    signal led       : std_logic_vector (7 downto 0);
    signal seg       : std_logic_vector (6 downto 0);
    signal dp        : std_logic;
    signal an        : std_logic_vector (3 downto 0);

    constant clk_period : time := 10 ns;

begin

    uut: riscv Port map (
        btn_clk => btn_clk, clk => clk, btn_reset => btn_reset,
        swt => swt, led => led, seg => seg, dp => dp, an => an
    );

    clk_process :process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    stim_proc: process
    begin
        -- 1. Secuencia de encendido
        btn_reset <= '1';
        wait for 100 ns;
        btn_reset <= '0';
        wait for 100 ns;

        -- 2. Damos 60 pulsaciones para que le dé tiempo a dar unas 3 o 4 vueltas al bucle
        for i in 1 to 60 loop
            btn_clk <= '1';
            wait for 200 ns; 
            btn_clk <= '0';
            wait for 200 ns;
        end loop;

        -- Fin de la simulación
        wait;
    end process;
end behavior;