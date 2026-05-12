library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_display_manager is
end tb_display_manager;

architecture Behavioral of tb_display_manager is

    component display_manager
        Port (
            clk         : in  std_logic;
            reset       : in  std_logic;
            cpu_opcode  : in  std_logic_vector(6 downto 0);
            cpu_reg     : in  std_logic_vector(4 downto 0);
            cpu_val     : in  std_logic_vector(15 downto 0);
            lcd_busy    : in  std_logic;
            char_out    : out std_logic_vector(7 downto 0);
            char_we     : out std_logic;
            cmd_out     : out std_logic_vector(7 downto 0);
            cmd_we      : out std_logic
        );
    end component;

    signal clk          : std_logic := '0';
    signal reset        : std_logic := '1';
    signal cpu_opcode   : std_logic_vector(6 downto 0) := "0110011"; -- x33
    signal cpu_reg      : std_logic_vector(4 downto 0) := "01010";   -- x0A
    signal cpu_val      : std_logic_vector(15 downto 0) := x"ABCD";
    signal lcd_busy     : std_logic := '0';
    
    signal char_out     : std_logic_vector(7 downto 0);
    signal char_we      : std_logic;
    signal cmd_out      : std_logic_vector(7 downto 0);
    signal cmd_we       : std_logic;

    constant clk_period : time := 10 ns;

begin

    uut: display_manager port map (
        clk => clk, reset => reset, 
        cpu_opcode => cpu_opcode, cpu_reg => cpu_reg, cpu_val => cpu_val,
        lcd_busy => lcd_busy, char_out => char_out, char_we => char_we,
        cmd_out => cmd_out, cmd_we => cmd_we
    );

    clk_process : process begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    -- Emulador de LCD Busy (responde a los WE)
    busy_emu : process(clk)
        variable counter : integer := 0;
    begin
        if rising_edge(clk) then
            if (char_we = '1' or cmd_we = '1') then
                lcd_busy <= '1';
                counter := 3; -- Simula un pequeño retraso
            elsif counter > 0 then
                counter := counter - 1;
            else
                lcd_busy <= '0';
            end if;
        end if;
    end process;

    stim_proc: process
    begin		
        reset <= '1';
        wait for 50 ns;
        reset <= '0';
        
        -- En este punto la máquina esperará a que pase el REFRESH_MAX
        wait until cmd_we = '1';
        
        -- Dejamos que haga el ciclo de 32 caracteres...
        for i in 0 to 32 loop
            wait until char_we = '1' or cmd_we = '1';
        end loop;

        -- Cambiamos un dato para el siguiente ciclo
        wait for 100 ns;
        cpu_val <= x"1234";

        wait;
    end process;

end Behavioral;