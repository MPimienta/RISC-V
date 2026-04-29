library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_registers is
end tb_registers;

architecture behavior of tb_registers is 

    component registers
    Port ( 
        clk        : in  STD_LOGIC;
        reset      : in  STD_LOGIC;
        reg_write  : in  STD_LOGIC;
        rs1_addr   : in  STD_LOGIC_VECTOR (2 downto 0);
        rs2_addr   : in  STD_LOGIC_VECTOR (2 downto 0);
        rd_addr    : in  STD_LOGIC_VECTOR (2 downto 0);
        write_data : in  STD_LOGIC_VECTOR (7 downto 0);
        rs1_data   : out STD_LOGIC_VECTOR (7 downto 0);
        rs2_data   : out STD_LOGIC_VECTOR (7 downto 0)
    );
    end component;

    signal clk        : std_logic := '0';
    signal reset      : std_logic := '0';
    signal reg_write  : std_logic := '0';
    signal rs1_addr   : std_logic_vector(2 downto 0) := (others => '0');
    signal rs2_addr   : std_logic_vector(2 downto 0) := (others => '0');
    signal rd_addr    : std_logic_vector(2 downto 0) := (others => '0');
    signal write_data : std_logic_vector(7 downto 0) := (others => '0');
    
    signal rs1_data   : std_logic_vector(7 downto 0);
    signal rs2_data   : std_logic_vector(7 downto 0);

    constant clk_period : time := 10 ns;

begin

    uut: registers PORT MAP (
          clk => clk,
          reset => reset,
          reg_write => reg_write,
          rs1_addr => rs1_addr,
          rs2_addr => rs2_addr,
          rd_addr => rd_addr,
          write_data => write_data,
          rs1_data => rs1_data,
          rs2_data => rs2_data
        );

    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
    begin		
    
        reset <= '1';
        wait for 20 ns;	
        reset <= '0';
        wait for clk_period;

        reg_write <= '1';
        rd_addr <= "001"; 
        write_data <= x"AA";
        wait for clk_period;
        reg_write <= '0'; 
        wait for clk_period;

        rs1_addr <= "001";
        rs2_addr <= "010";
        wait for clk_period;

        reg_write <= '1';
        rd_addr <= "000";
        write_data <= x"FF"; 
        wait for clk_period;
        reg_write <= '0';
        

        rs1_addr <= "000"; 
        wait for clk_period;

        reg_write <= '1';
        rd_addr <= "111"; 
        write_data <= x"55"; 
        rs2_addr <= "111"; 
        wait for clk_period;
        reg_write <= '0';

        wait;
    end process;

end behavior;