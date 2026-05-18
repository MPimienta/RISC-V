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
        
        -- ==========================================
        -- 0-8: ENCENDIDO Y RETARDO 
        -- ==========================================
        0 => x"47F0",
1 => x"4DE0",
2 => x"4800",
3 => x"4E10",
4 => x"4408",
5 => x"24C2",
6 => x"440A",
7 => x"24C2",
8 => x"441A",
9 => x"24C2",
10 => x"44AE",
11 => x"7227",
12 => x"448D",
13 => x"7225",
14 => x"4414",
15 => x"7223",
16 => x"4420",
17 => x"7221",
18 => x"4400",
19 => x"721F",
20 => x"44AF",
21 => x"721D",
22 => x"441B",
23 => x"24C2",
24 => x"4A04",
25 => x"4880",
26 => x"4400",
27 => x"7217",
28 => x"393F",
29 => x"683D",
30 => x"3B7F",
31 => x"6A3A",
32 => x"4800",
33 => x"441A",
34 => x"24C2",
35 => x"4421",
36 => x"720E",
37 => x"4400",
38 => x"720C",
39 => x"447F",
40 => x"720A",
41 => x"4422",
42 => x"7208",
43 => x"4400",
44 => x"7206",
45 => x"4403",
46 => x"7204",
47 => x"441B",
48 => x"24C2",
49 => x"7005",
50 => x"24C3",
51 => x"14C4",
52 => x"643F",
53 => x"8040",
54 => x"1B82",
55 => x"057D",
56 => x"643E",
57 => x"2B00",
58 => x"4411",
59 => x"6A82",
60 => x"7008",
61 => x"4412",
62 => x"6A82",
63 => x"7010",
64 => x"1B82",
65 => x"057D",
66 => x"543E",
67 => x"71F3",
68 => x"4400",
69 => x"73ED",
70 => x"4442",
71 => x"73EB",
72 => x"447F",
73 => x"73E9",
74 => x"4440",
75 => x"73E7",
76 => x"4400",
77 => x"73E5",
78 => x"71F2",
79 => x"4442",
80 => x"73E2",
81 => x"4461",
82 => x"73E0",
83 => x"4451",
84 => x"73DE",
85 => x"4449",
86 => x"73DC",
87 => x"4446",
88 => x"73DA",
89 => x"71E7",
others => x"0000"
);
begin

    instruction_out <= rom_memory(to_integer(unsigned(instruction_addr)));


end DataFlow;
