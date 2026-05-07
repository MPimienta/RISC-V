library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity i2c_master is
    Generic (
        input_clk : integer := 100_000_000; -- 100MHz (Basys 3)
        bus_clk   : integer := 100_000      -- 100kHz (I2C Estándar)
    );
    Port (
        clk       : in     std_logic;
        reset     : in     std_logic;
        ena       : in     std_logic;                    -- Iniciar transmisión
        addr      : in     std_logic_vector(6 downto 0); -- Dirección del esclavo (LCD suele ser 0x27)
        rw        : in     std_logic;                    -- '0' escribir, '1' leer
        data_wr   : in     std_logic_vector(7 downto 0); -- Byte a enviar
        busy      : out    std_logic;                    -- '1' mientras transmite
        ack_error : out    std_logic;                    -- '1' si no hubo respuesta (ACK)
        sda       : inout  std_logic;                    -- Pin físico SDA
        scl       : inout  std_logic                     -- Pin físico SCL
    );
end i2c_master;

architecture Behavioral of i2c_master is
    -- Cálculo del divisor (generamos un reloj 4 veces más rápido que el bus para los sub-estados)
    constant divider  : integer := (input_clk / bus_clk) / 4;
    
    -- Definición de la FSM (Estilo Behavioral)
    type state_type is (ready, start, command, slv_ack1, wr, slv_ack2, stop);
    signal state      : state_type := ready;
    
    -- Señales de control interno
    signal data_clk   : std_logic;                   -- Reloj para manejar SDA
    signal scl_clk    : std_logic;                   -- Reloj que saldrá a SCL
    signal scl_ena    : std_logic := '0';            -- Habilitador de salida de reloj
    signal sda_int    : std_logic := '1';            -- Registro interno de SDA
    signal addr_rw    : std_logic_vector(7 downto 0);
    signal data_tx    : std_logic_vector(7 downto 0);
    signal bit_cnt    : integer range 0 to 7 := 7;
begin

    -- GENERADOR DE RELOJ INTERNO (Pre-scaler)
    -- Divide los 100MHz en pulsos que la FSM usará para coordinar SDA y SCL
    process(clk)
        variable count : integer range 0 to divider*4;
    begin
        if rising_edge(clk) then
            if reset = '1' then
                count := 0;
            else
                if count = (divider*4 - 1) then
                    count := 0;
                else
                    count := count + 1;
                end if;
                
                -- Generamos fases para que SDA cambie cuando SCL está en bajo
                if count < divider then
                    scl_clk <= '0'; data_clk <= '0';
                elsif count < divider*2 then
                    scl_clk <= '0'; data_clk <= '1';
                elsif count < divider*3 then
                    scl_clk <= '1'; data_clk <= '1';
                else
                    scl_clk <= '1'; data_clk <= '0';
                end if;
            end if;
        end if;
    end process;

    -- FSM: LÓGICA DE CONTROL I2C
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= ready;
                busy <= '1';
                scl_ena <= '0';
                sda_int <= '1';
                ack_error <= '0';
            elsif data_clk = '1' then
                case state is
                    when ready =>
                        if ena = '1' then
                            busy <= '1';
                            addr_rw <= addr & rw;
                            data_tx <= data_wr;
                            state <= start;
                        else
                            busy <= '0';
                            state <= ready;
                        end if;

                    when start =>
                        sda_int <= '0'; -- Condición de START (SDA cae mientras SCL es alto)
                        scl_ena <= '1';
                        state <= command;

                    when command =>
                        sda_int <= addr_rw(bit_cnt);
                        if bit_cnt = 0 then
                            bit_cnt <= 7;
                            state <= slv_ack1;
                        else
                            bit_cnt <= bit_cnt - 1;
                        end if;

                    when slv_ack1 =>
                        sda_int <= '1'; -- Soltamos SDA (High-Z) para leer el ACK
                        state <= wr;

                    when wr =>
                        sda_int <= data_tx(bit_cnt);
                        if bit_cnt = 0 then
                            bit_cnt <= 7;
                            state <= slv_ack2;
                        else
                            bit_cnt <= bit_cnt - 1;
                        end if;

                    when slv_ack2 =>
                        sda_int <= '1'; -- Soltamos SDA para leer el segundo ACK
                        state <= stop;

                    when stop =>
                        sda_int <= '1'; -- Condición de STOP (SDA sube mientras SCL es alto)
                        scl_ena <= '0';
                        state <= ready;
                end case;
            end if;
        end if;
    end process;

    -- LÓGICA DE SALIDA TRISTATE (Imprescindible en I2C)
    -- El I2C no envía un '1', "suelta" el cable para que la resistencia Pull-up lo suba.
    scl <= '0' when (scl_ena = '1' and scl_clk = '0') else 'Z';
    sda <= '0' when (sda_int = '0') else 'Z';

end Behavioral;