library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity i2c_master is
    Generic (
        input_clk : integer := 100_000_000; -- 100MHz (Basys 3)
        bus_clk   : integer := 100_000      -- 100kHz (I2C Estándar)
    );
    Port (
        clk       : in    std_logic;
        reset     : in    std_logic;
        ena       : in    std_logic;                    -- Mantener a '1' para ráfagas
        addr      : in    std_logic_vector(6 downto 0); -- Dirección (0x27)
        rw        : in    std_logic;                    -- '0' escribir, '1' leer
        data_wr   : in    std_logic_vector(7 downto 0); -- Byte a enviar
        busy      : out   std_logic;                    -- '1' mientras transmite
        ack_error : out   std_logic;                    -- '1' si no hubo ACK
        sda       : inout std_logic;
        scl       : inout std_logic
    );
end i2c_master;

architecture Behavioral of i2c_master is
    constant divider : integer := (input_clk / bus_clk) / 4; 
    
    type state_type is (ready, start, command, slv_ack1, wr, slv_ack2, stop);
    signal state : state_type := ready;
    
    signal data_clk_tick : std_logic := '0';
    signal scl_clk       : std_logic := '1';
    signal scl_ena       : std_logic := '0';
    signal sda_int       : std_logic := '1';
    
    signal addr_rw       : std_logic_vector(7 downto 0);
    signal data_tx       : std_logic_vector(7 downto 0);
    signal bit_cnt       : integer range 0 to 7 := 7;
begin

    -- Generador de Ticks (4 pulsos por ciclo de SCL)
    process(clk)
        variable count : integer range 0 to divider*4 := 0;
    begin
        if rising_edge(clk) then
            if reset = '1' then
                count := 0;
                data_clk_tick <= '0';
            else
                if count = (divider*4 - 1) then
                    count := 0;
                else
                    count := count + 1;
                end if;
                
                -- Tick de habilitación un ciclo de reloj antes de cambiar fases
                if count = 0 or count = divider or count = divider*2 or count = divider*3 then
                    data_clk_tick <= '1';
                else
                    data_clk_tick <= '0';
                end if;

                -- Fases del reloj SCL
                if count < divider then
                    scl_clk <= '0';
                elsif count < divider*3 then
                    scl_clk <= '1';
                else
                    scl_clk <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Máquina de Estados Principal
    process(clk)
        variable phase : integer range 0 to 3 := 0;
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= ready;
                busy <= '1';
                scl_ena <= '0';
                sda_int <= '1';
                ack_error <= '0';
                phase := 0;
            elsif data_clk_tick = '1' then
                phase := (phase + 1) mod 4; -- Cuenta fases: 0 (Data change), 1 (SCL rises), 2 (SCL high), 3 (SCL falls)
                
                case state is
                    when ready =>
                        busy <= '0';
                        scl_ena <= '0';
                        sda_int <= '1';
                        if ena = '1' then
                            busy <= '1';
                            addr_rw <= addr & rw;
                            data_tx <= data_wr;
                            state <= start;
                            phase := 0;
                        end if;

                    when start =>
                        busy <= '1';
                        scl_ena <= '1';
                        if phase = 0 then sda_int <= '1'; -- Asegura SDA alto
                        elsif phase = 1 then sda_int <= '0'; -- Baja SDA con SCL alto (START)
                        elsif phase = 3 then state <= command; bit_cnt <= 7; end if;

                    when command =>
                        if phase = 0 then sda_int <= addr_rw(bit_cnt); -- Prepara dato
                        elsif phase = 3 then
                            if bit_cnt = 0 then state <= slv_ack1;
                            else bit_cnt <= bit_cnt - 1; end if;
                        end if;

                    when slv_ack1 =>
                        if phase = 0 then sda_int <= '1'; -- Libera bus
                        elsif phase = 2 then ack_error <= sda; -- LECTURA REAL DEL ACK
                        elsif phase = 3 then state <= wr; bit_cnt <= 7; end if;

                    when wr =>
                        if phase = 0 then sda_int <= data_tx(bit_cnt);
                        elsif phase = 3 then
                            if bit_cnt = 0 then state <= slv_ack2;
                            else bit_cnt <= bit_cnt - 1; end if;
                        end if;

                    when slv_ack2 =>
                        if phase = 0 then sda_int <= '1'; -- Libera bus
                        elsif phase = 2 then ack_error <= sda; -- LECTURA REAL DEL ACK
                        elsif phase = 3 then
                            -- Si Enable sigue alto, permitimos ráfaga (enviamos nuevo byte)
                            if ena = '1' then 
                                data_tx <= data_wr;
                                bit_cnt <= 7;
                                state <= wr;
                            else 
                                state <= stop; 
                            end if;
                        end if;

                    when stop =>
                        if phase = 0 then sda_int <= '0'; -- Prepara parada
                        elsif phase = 2 then sda_int <= '1'; -- Sube SDA con SCL alto (STOP)
                        elsif phase = 3 then scl_ena <= '0'; state <= ready; end if;
                end case;
            end if;
        end if;
    end process;

    -- Salidas Tristate físicas
    scl <= '0' when (scl_ena = '1' and scl_clk = '0') else 'Z';
    sda <= '0' when (sda_int = '0') else 'Z';

end Behavioral;