library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALU_tb is
end ALU_tb;

architecture Behavioral of ALU_tb is

component ALU
        Port ( 
            A        : in  std_logic_vector(7 downto 0);
            B        : in  std_logic_vector(7 downto 0);
            ALU_Sel  : in  std_logic_vector(2 downto 0);
            Result   : out std_logic_vector(7 downto 0);
            Zero     : out std_logic
        );
    end component;

    signal A_tb       : std_logic_vector(7 downto 0) := (others => '0');
    signal B_tb       : std_logic_vector(7 downto 0) := (others => '0');
    signal ALU_Sel_tb : std_logic_vector(2 downto 0) := (others => '0');
    signal Result_tb  : std_logic_vector(7 downto 0);
    signal Zero_tb    : std_logic;

begin

    uut: ALU port map (
        A => A_tb,
        B => B_tb,
        ALU_Sel => ALU_Sel_tb,
        Result => Result_tb,
        Zero => Zero_tb
        );
        
        stim_proc: process
        begin		
            -- Prueba 1: Suma (5 + 3)
            A_tb <= "00000101"; -- 5
            B_tb <= "00000011"; -- 3
            ALU_Sel_tb <= "000";
            wait for 20 ns;

            -- Prueba 2: Resta (10 - 4)
            A_tb <= "00001010"; -- 10
            B_tb <= "00000100"; -- 4
            ALU_Sel_tb <= "001";
            wait for 20 ns;

            -- Prueba 3: Flag Zero (5 - 5)
            A_tb <= "00000101"; -- 5
            B_tb <= "00000101"; -- 5
            ALU_Sel_tb <= "001";
            wait for 20 ns;

            -- Prueba 4: Operación AND
            A_tb <= "11110000";
            B_tb <= "10101010";
            ALU_Sel_tb <= "010";
            wait for 20 ns;
            
            -- Prueba 5: OR 
            -- A = 10100000, B = 00001010 -> Result = 10101010
            A_tb <= "10100000"; 
            B_tb <= "00001010"; 
            ALU_Sel_tb <= "011";
            wait for 20 ns;

            -- Prueba 6: LI (Load Immediate)
            A_tb <= "11111111"; 
            B_tb <= "01010101"; 
            ALU_Sel_tb <= "100";
            wait for 20 ns;
        
            -- Prueba 7: Caso Others
            A_tb <= "11001100"; 
            B_tb <= "00110011"; 
            ALU_Sel_tb <= "111";
            wait for 20 ns;

            -- Prueba 8: Flag Zero con AND que da 0
            A_tb <= "10101010"; 
            B_tb <= "01010101"; 
            ALU_Sel_tb <= "010";
            wait for 20 ns;

            wait;
    end process;

end Behavioral;
