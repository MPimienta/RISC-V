library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU_tb is
-- Entidad vacía
end ALU_tb;

architecture Behavioral of ALU_tb is

    -- Componente a probar
    component ALU
        Port ( 
            A        : in  std_logic_vector(7 downto 0);
            B        : in  std_logic_vector(7 downto 0);
            ALU_Sel  : in  std_logic_vector(2 downto 0);
            Result   : out std_logic_vector(7 downto 0);
            Zero     : out std_logic
        );
    end component;

    -- Señales de interconexión
    signal A_tb       : std_logic_vector(7 downto 0) := (others => '0');
    signal B_tb       : std_logic_vector(7 downto 0) := (others => '0');
    signal ALU_Sel_tb : std_logic_vector(2 downto 0) := (others => '0');
    signal Result_tb  : std_logic_vector(7 downto 0);
    signal Zero_tb    : std_logic;

begin

    -- Instancia de la ALU
    uut: ALU port map (
        A       => A_tb,
        B       => B_tb,
        ALU_Sel => ALU_Sel_tb,
        Result  => Result_tb,
        Zero    => Zero_tb
    );

    -- Proceso de estímulos
    stim_proc: process
    begin
        -- 000: ADD
        A_tb <= std_logic_vector(to_unsigned(15, 8));
        B_tb <= std_logic_vector(to_unsigned(10, 8));
        ALU_Sel_tb <= "000";
        wait for 20 ns;

        -- 001: SUB y Flag Zero
        A_tb <= std_logic_vector(to_unsigned(20, 8));
        B_tb <= std_logic_vector(to_unsigned(20, 8));
        ALU_Sel_tb <= "001";
        wait for 20 ns;

        -- 010: AND
        A_tb <= "10101010"; B_tb <= "11110000";
        ALU_Sel_tb <= "010";
        wait for 20 ns;

        -- 011: OR
        A_tb <= "10101010"; B_tb <= "01010101";
        ALU_Sel_tb <= "011";
        wait for 20 ns;

        -- 100: SLL
        A_tb <= "00000001"; B_tb <= "00000110";
        ALU_Sel_tb <= "100";
        wait for 20 ns;

        -- 101: SLT (Caso TRUE: -5 < 2)
        -- A = (-5 en compl. a 2)
        A_tb <= "11111011"; B_tb <= "00000010";
        ALU_Sel_tb <= "101";
        wait for 20 ns;

        -- 110: XOR (0xFF XOR 0x0F = 0xF0)
        A_tb <= "11111111"; B_tb <= "00001111";
        ALU_Sel_tb <= "110";
        wait for 20 ns;

        -- 111: LI
        A_tb <= "10101010"; B_tb <= "00111100";
        ALU_Sel_tb <= "111";
        wait for 20 ns;

        wait;
    end process;

end Behavioral;