----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/25/2026 09:48:35 PM
-- Design Name: 
-- Module Name: rom_instructions - DataFlow
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rom_instructions is
    Port (
        instruction_out     :   out std_logic_vector(15 downto 0);
        instruction_addr    :   in std_logic_vector (15 downto 0)   
    );
end rom_instructions;


architecture DataFlow of rom_instructions is

    type instruction_array is array (0 to 2047) of STD_LOGIC_VECTOR(15 downto 0); -- 256 espacios de 8 bits
    
    -- De momento se deja hardcodeado, pero hay que investigar cómo cargar un programa en memoria.
constant rom_memory : instruction_array := (
0 => x"4201",
1 => x"47F0",
2 => x"4DE0",
3 => x"4800",
4 => x"4E10",
5 => x"441B",
6 => x"24C2",
7 => x"1B82",
8 => x"057D",
9 => x"643E",
10 => x"2B00",
11 => x"4411",
12 => x"6A82",
13 => x"7208",
14 => x"4412",
15 => x"6A82",
16 => x"721A",
17 => x"1B82",
18 => x"057D",
19 => x"543E",
20 => x"73F3",
21 => x"14C4",
22 => x"643F",
23 => x"4400",
24 => x"24C3",
25 => x"14C4",
26 => x"643F",
27 => x"4442",
28 => x"24C3",
29 => x"14C4",
30 => x"643F",
31 => x"447F",
32 => x"24C3",
33 => x"14C4",
34 => x"643F",
35 => x"4440",
36 => x"24C3",
37 => x"14C4",
38 => x"643F",
39 => x"4400",
40 => x"24C3",
41 => x"73E8",
42 => x"14C4",
43 => x"643F",
44 => x"4442",
45 => x"24C3",
46 => x"14C4",
47 => x"643F",
48 => x"4461",
49 => x"24C3",
50 => x"14C4",
51 => x"643F",
52 => x"4451",
53 => x"24C3",
54 => x"14C4",
55 => x"643F",
56 => x"4449",
57 => x"24C3",
58 => x"14C4",
59 => x"643F",
60 => x"4446",
61 => x"24C3",
62 => x"73D3",
others => x"0000"

    );
begin

    instruction_out <= rom_memory(to_integer(unsigned(instruction_addr)));


end DataFlow;
