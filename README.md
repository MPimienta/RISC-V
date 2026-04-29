# RISC-V
A RISC-V inspired CPU implemented on an FPGA using vhdl
While the architecture used in the CPU is similar to the RISC-V, it contains some major diferences.
First of all, for this project we are building an 8-bit cpu with 16-bit instructions. Since it is an 8-bit architecture, we need to read each instruction in two cycles and use an instruction register to save the information of the instruction.

The instructions will have a fixed length of 16 bits. Depending on the type of instruction, the bits are distributed as follows:

**Legend for bit placeholders:**
* `ddd`: 3 bits for the destination register (rd).
* `ss1`: 3 bits for the first source register (rs1).
* `ss2`: 3 bits for the second source register (rs2).
* `iii`: Bits for Immediate values (constants/offsets).

---

## Instructions

### Type R (Register to Register)
**Format:** `[Opcode: 4] | [ddd: 3] | [ss1: 3] | [ss2: 3] | [func: 3]`
*(All Type R instructions share the Opcode `0000` and are identified by the `func` bits).*

* ADD (Addition): `0000 ddd ss1 ss2 000`
* SUB (Substraction): `0000 ddd ss1 ss2 001`
* AND (Logical AND): `0000 ddd ss1 ss2 010`
* OR (Logical OR): `0000 ddd ss1 ss2 011`
* SLL (Shift Left Logical): `0000 ddd ss1 ss2 100`
* SLT (Set Less Than): `0000 ddd ss1 ss2 101`

### Memory and Immediate
**Format (I-Type):** `[Opcode: 4] | [ddd/ss2: 3] | [ss1: 3] | [Immediate: 6]`
*(For `LI`, the format uses 9 bits for the immediate: `[Opcode: 4] | [ddd: 3] | [Immediate: 9]`)*

* LW (Load Word/Byte): `0001 ddd ss1 iiiiii`
* SW (Store Word/Byte): `0010 ss2 ss1 iiiiii` *(Note: ss2 is the data to store, ss1 is the base address)*
* ADDI (ADD Immediate): `0011 ddd ss1 iiiiii`
* LI (Load Immediate): `0100 ddd iiiiiiiii`

### Flow Control (Branches and Jumps)
**Format (Branch):** `[Opcode: 4] | [ss1: 3] | [ss2: 3] | [Immediate: 6]`
**Format (Jump):** `[Opcode: 4] | [ddd: 3] | [Immediate: 9]`

* BEQ (Branch if Equal): `0101 ss1 ss2 iiiiii`
* BNE (Branch if Not Equal): `0110 ss1 ss2 iiiiii`
* JAL (Jump And Link): `0111 ddd iiiiiiiii`
* JALR (Jump and Link Register): `1000 ddd ss1 iiiiii`

### Others
* NOP (No Operation): `0000 000 000 000 000` *(Hardware equivalent to `ADD r0, r0, r0`)*
* XOR (Exclusive OR): `0000 ddd ss1 ss2 110` *(Operates as a Type R instruction)*

---

## Register Map
The CPU features 8 general-purpose registers (8-bit wide). To maintain RISC conventions, some registers have dedicated roles:

| Register | Name | Description |
| :---: | :---: | :--- |
| **R0** | `zero` | Hardwired to 0. Cannot be overwritten. |
| **R1** | `ra` | Return Address (Used by JAL / JALR). |
| **R2** | `sp` | Stack Pointer (Optional, for memory management). |
| **R3-R7** | `t0-t4`| Temporary variables for general use. |


---

## Memory Map (MMIO)
The system uses Memory-Mapped I/O. The 8-bit address space (256 addresses) is divided as follows:

| Address Range (Hex) | Description | Access |
| :--- | :--- | :---: |
| `0x00` - `0x7F` | Data RAM (Variables) | R/W |
| `0xE0` | Switches Input (Basys 3) | Read Only |
| `0xE1` | Buttons Input (Basys 3) | Read Only |
| `0xF0` | LEDs Output (Basys 3) | Write Only |
| `0xF1` | 7-Segment Display Output | Write Only |
*(Note: These addresses are provisional and can be adjusted during development).*

---

## Hardware & Tools
* **Target Board:** Digilent Basys 3 (Xilinx Artix-7 FPGA).
* **Language:** VHDL.
* **IDE/Synthesis:** Xilinx Vivado.
* **Microarchitecture:** Multicycle (3-state FSM: Fetch High, Fetch Low, Execute).
