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
            swt         : in std_logic_vector (15 downto 0);
            led         : out std_logic_vector (15 downto 0);
            seg         : out std_logic_vector (6 downto 0);
            dp          : out std_logic;
            an          : out std_logic_vector (3 downto 0);
            keypad_col : in std_logic_vector(3 downto 0);
            keypad_row : out std_logic_vector(3 downto 0)
        );
    end component;

    signal btn_clk   : std_logic := '0';
    signal clk       : std_logic := '0';
    signal btn_reset : std_logic := '0';
    signal swt       : std_logic_vector (15 downto 0) := (others => '0');
    signal led       : std_logic_vector (15 downto 0);
    signal seg       : std_logic_vector (6 downto 0);
    signal dp        : std_logic;
    signal an        : std_logic_vector (3 downto 0);
    signal keypad_col : std_logic_vector(3 downto 0) := "1111";
    signal keypad_row : std_logic_vector(3 downto 0);
    
    

    constant clk_period : time := 10 ns;

begin

    uut: riscv Port map (
        btn_clk => btn_clk, clk => clk, btn_reset => btn_reset,
        swt => swt, led => led, seg => seg, dp => dp, an => an,
        keypad_col => keypad_col, keypad_row => keypad_row  
    );

    clk_process :process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    stim_proc: process
    begin
        swt(2) <= '1';
        swt(4) <= '1';
        swt(6) <= '1';
        btn_reset <= '1';
        wait for 100 ns;
        btn_reset <= '0';
        wait for 100 ns;
        
        wait for 500 ns;
        
        wait until keypad_row = "1101";
        
        keypad_col <= "1101";

        for i in 1 to 20 loop
            btn_clk <= '1';
            wait for 200 ns; 
            btn_clk <= '0';
            wait for 200 ns;
        end loop;
        
        wait for 500 ns;
        
        for i in 1 to 80 loop
            btn_clk <= '1';
            wait for 200 ns; 
            btn_clk <= '0';
            wait for 200 ns;
        end loop;
        
      

        wait;
    end process;
end behavior;library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity riscv_tb is
end riscv_tb;

architecture behavior of riscv_tb is

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

    signal btn_clk   : std_logic := '0';
    signal clk       : std_logic := '0';
    signal btn_reset : std_logic := '0';
    signal swt       : std_logic_vector (15 downto 0) := (others => '0');
    signal led       : std_logic_vector (15 downto 0);
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
        swt(2) <= '1';
        swt(4) <= '1';
        swt(6) <= '1';
        btn_reset <= '1';
        wait for 100 ns;
        btn_reset <= '0';
        wait for 100 ns;

        for i in 1 to 100 loop
            btn_clk <= '1';
            wait for 200 ns; 
            btn_clk <= '0';
            wait for 200 ns;
        end loop;

        wait;
    end process;
end behavior;
