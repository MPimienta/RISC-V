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
11 => x"7233",
12 => x"44D5",
13 => x"7231",
14 => x"4480",
15 => x"722F",
16 => x"44A8",
17 => x"722D",
18 => x"441F",
19 => x"722B",
20 => x"4420",
21 => x"7229",
22 => x"4400",
23 => x"7227",
24 => x"448D",
25 => x"7225",
26 => x"4414",
27 => x"7223",
28 => x"44A1",
29 => x"7221",
30 => x"44C8",
31 => x"721F",
32 => x"44AF",
33 => x"721D",
34 => x"441B",
35 => x"24C2",
36 => x"4A04",
37 => x"4880",
38 => x"4400",
39 => x"7217",
40 => x"393F",
41 => x"683D",
42 => x"3B7F",
43 => x"6A3A",
44 => x"4800",
45 => x"441A",
46 => x"24C2",
47 => x"4421",
48 => x"720E",
49 => x"4400",
50 => x"720C",
51 => x"447F",
52 => x"720A",
53 => x"4422",
54 => x"7208",
55 => x"4400",
56 => x"7206",
57 => x"4400",
58 => x"7204",
59 => x"441B",
60 => x"24C2",
61 => x"7005",
62 => x"24C3",
63 => x"14C4",
64 => x"643F",
65 => x"8040",
66 => x"1B82",
67 => x"057D",
68 => x"643E",
69 => x"2B00",
70 => x"4411",
71 => x"6A82",
72 => x"7008",
73 => x"4412",
74 => x"6A82",
75 => x"7010",
76 => x"1B82",
77 => x"057D",
78 => x"543E",
79 => x"71F3",
80 => x"4400",
81 => x"73ED",
82 => x"4442",
83 => x"73EB",
84 => x"447F",
85 => x"73E9",
86 => x"4440",
87 => x"73E7",
88 => x"4400",
89 => x"73E5",
90 => x"71F2",
91 => x"4442",
92 => x"73E2",
93 => x"4461",
94 => x"73E0",
95 => x"4451",
96 => x"73DE",
97 => x"4449",
98 => x"73DC",
99 => x"4446",
100 => x"73DA",
101 => x"71E7",
others => x"0000"

);
begin

    instruction_out <= rom_memory(to_integer(unsigned(instruction_addr)));


end DataFlow;
