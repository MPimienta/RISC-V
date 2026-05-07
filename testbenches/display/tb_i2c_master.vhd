library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_i2c_master is
end tb_i2c_master;

architecture sim of tb_i2c_master is
    signal clk       : std_logic := '0';
    signal reset     : std_logic := '1';
    signal ena       : std_logic := '0';
    signal addr      : std_logic_vector(6 downto 0) := "0100111"; -- 0x27
    signal data_wr   : std_logic_vector(7 downto 0) := x"A5";     -- Dato prueba
    signal busy      : std_logic;
    signal sda       : std_logic := 'H'; -- 'H' simula resistencia Pull-up
    signal scl       : std_logic := 'H';

begin
    -- Instancia
    uut: entity work.i2c_master
        port map ( clk => clk, reset => reset, ena => ena, addr => addr,
                   rw => '0', data_wr => data_wr, busy => busy,
                   ack_error => open, sda => sda, scl => scl );

    clk <= not clk after 5 ns; -- 100MHz

    process
    begin
        reset <= '1'; wait for 100 ns;
        reset <= '0'; wait for 100 ns;
        
        -- Iniciar transmisión
        ena <= '1';
        wait until busy = '1';
        ena <= '0';
        
        wait until busy = '0';
        wait for 1 ms; -- Esperar a ver la trama completa
        assert false report "Fin de simulación" severity failure;
    end process;
end sim;