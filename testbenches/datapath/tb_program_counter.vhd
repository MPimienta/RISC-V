library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_program_counter is
end tb_program_counter;

architecture Behavioral of tb_program_counter is

    component program_counter
        Port (
            clk      : in  std_logic;
            reset    : in  std_logic;
            load     : in  std_logic;
            d_in     : in  std_logic_vector(7 downto 0);
            pc_out   : out std_logic_vector(7 downto 0)
        );
    end component;

    signal clk_tb   : std_logic := '0';
    signal reset_tb : std_logic := '0';
    signal load_tb  : std_logic := '0';
    signal d_in_tb  : std_logic_vector(7 downto 0) := (others => '0');
    signal pc_out_tb: std_logic_vector(7 downto 0);

    constant clk_period : time := 10 ns;

begin

    uut: program_counter port map (
          clk    => clk_tb,
          reset  => reset_tb,
          load   => load_tb,
          d_in   => d_in_tb,
          pc_out => pc_out_tb
        );

    clk_process : process
    begin
        clk_tb <= '0';
        wait for clk_period/2;
        clk_tb <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
    begin		
        reset_tb <= '1';
        wait for 20 ns;
        reset_tb <= '0';
        wait for clk_period;
        -- pc_out debería ser 0x00

        -- Escenario 2: Incremento secuencial (Simulando FETCH)
        -- Dejamos que el PC cuente unos ciclos
        wait for clk_period * 5;
        -- Verificación: pc_out debería haber llegado a 0x05

        -- Escenario 3: Ejecución de un Salto (BEQ / JAL)
        d_in_tb <= X"20"; -- Dirección de destino (32 en decimal)
        load_tb <= '1';
        wait for clk_period;
        load_tb <= '0'; -- Desactivamos el salto para que siga contando desde ahí
        
        wait for clk_period * 3;
        -- Verificación: pc_out debería mostrar 0x20, 0x21, 0x22...

        wait;
    end process;

end Behavioral;
