#!/usr/bin/env python3
import sys
import re

REGISTERS = {
    'r0': '000',
    'r1': '001',
    'r2': '010',
    'r3': '011',
    'r4': '100',
    'r5': '101',
    'r6': '110',
    'r7': '111',
}

R_TYPE_FUNCS = {
    'add': '000',
    'sub': '001',
    'and': '010',
    'or':  '011',
    'sll': '100',
    'slt': '101',
    'xor': '110'
}

def to_bin(val, bits):
    if val < 0:
        val = (1 << bits) + val
    if val < 0 or val >= (1 << bits):
        raise ValueError(f"Value out of bounds for {bits} bits: {val}")
    return format(val, f'0{bits}b')

def parse_register(reg_str):
    reg = reg_str.lower().strip()
    if reg in REGISTERS:
        return REGISTERS[reg]
    raise ValueError(f"Unknown register: {reg_str}")

def parse_immediate(imm_str, labels, current_pc, bits, is_relative=False):
    imm_str = imm_str.strip()
    # Check if it's a label
    if imm_str in labels:
        target_pc = labels[imm_str]
        if is_relative:
            val = target_pc - current_pc
        else:
            val = target_pc
    else:
        # It's a number
        try:
            if imm_str.lower().startswith('0x'):
                val = int(imm_str, 16)
            elif imm_str.lower().startswith('0b'):
                val = int(imm_str, 2)
            else:
                val = int(imm_str)
        except ValueError:
            raise ValueError(f"Invalid immediate or unknown label: {imm_str}")
    
    return to_bin(val, bits)

def assemble(input_file, output_file):
    try:
        with open(input_file, 'r') as f:
            lines = f.readlines()
    except FileNotFoundError:
        print(f"Error: Input file '{input_file}' not found.")
        sys.exit(1)

    # Pass 1: Remove comments, empty lines, and record labels
    instructions = []
    labels = {}
    pc = 0

    for raw_line in lines:
        # Remove comments
        line = raw_line.split('#')[0].split(';')[0].strip()
        if not line:
            continue
        
        # Check for label
        if ':' in line:
            label_part, inst_part = line.split(':', 1)
            label = label_part.strip()
            labels[label] = pc
            line = inst_part.strip()
            if not line:
                continue
        
        instructions.append((pc, line, raw_line.strip()))
        pc += 1

    # Pass 2: Generate machine code
    machine_code = []

    for pc, line, raw_line in instructions:
        # Split by spaces or commas
        parts = re.split(r'[\s,]+', line)
        parts = [p for p in parts if p] # Remove empty strings
        if not parts:
            continue
            
        mnemonic = parts[0].lower()
        args = parts[1:]

        try:
            binary_inst = ""
            
            if mnemonic == 'nop':
                binary_inst = "0000000000000000"
                
            elif mnemonic in R_TYPE_FUNCS:
                # ADD ddd, ss1, ss2
                if len(args) != 3:
                    raise ValueError(f"{mnemonic.upper()} requires 3 arguments")
                ddd = parse_register(args[0])
                ss1 = parse_register(args[1])
                ss2 = parse_register(args[2])
                func = R_TYPE_FUNCS[mnemonic]
                binary_inst = f"0000{ddd}{ss1}{ss2}{func}"
                
            elif mnemonic == 'lw':
                # LW ddd, imm(ss1) or LW ddd, ss1, imm
                if len(args) == 2:
                    # LW ddd, imm(ss1)
                    ddd = parse_register(args[0])
                    match = re.match(r'(.+)\((.+)\)', args[1])
                    if not match:
                        raise ValueError("Invalid format for LW. Use 'LW rd, imm(rs1)'")
                    imm_str, ss1_str = match.groups()
                    ss1 = parse_register(ss1_str)
                    imm = parse_immediate(imm_str, labels, pc, 6)
                elif len(args) == 3:
                    # LW ddd, ss1, imm
                    ddd = parse_register(args[0])
                    ss1 = parse_register(args[1])
                    imm = parse_immediate(args[2], labels, pc, 6)
                else:
                    raise ValueError("LW requires 2 or 3 arguments")
                binary_inst = f"0001{ddd}{ss1}{imm}"
                
            elif mnemonic == 'sw':
                # SW ss2, imm(ss1) or SW ss2, ss1, imm
                if len(args) == 2:
                    # SW ss2, imm(ss1)
                    ss2 = parse_register(args[0])
                    match = re.match(r'(.+)\((.+)\)', args[1])
                    if not match:
                        raise ValueError("Invalid format for SW. Use 'SW rs2, imm(rs1)'")
                    imm_str, ss1_str = match.groups()
                    ss1 = parse_register(ss1_str)
                    imm = parse_immediate(imm_str, labels, pc, 6)
                elif len(args) == 3:
                    # SW ss2, ss1, imm
                    ss2 = parse_register(args[0])
                    ss1 = parse_register(args[1])
                    imm = parse_immediate(args[2], labels, pc, 6)
                else:
                    raise ValueError("SW requires 2 or 3 arguments")
                binary_inst = f"0010{ss2}{ss1}{imm}"
                
            elif mnemonic == 'addi':
                # ADDI ddd, ss1, imm
                if len(args) != 3:
                    raise ValueError("ADDI requires 3 arguments")
                ddd = parse_register(args[0])
                ss1 = parse_register(args[1])
                imm = parse_immediate(args[2], labels, pc, 6)
                binary_inst = f"0011{ddd}{ss1}{imm}"
                
            elif mnemonic == 'li':
                # LI ddd, imm
                if len(args) != 2:
                    raise ValueError("LI requires 2 arguments")
                ddd = parse_register(args[0])
                imm = parse_immediate(args[1], labels, pc, 9)
                binary_inst = f"0100{ddd}{imm}"
                
            elif mnemonic in ['beq', 'bne']:
                # BEQ ss1, ss2, imm
                if len(args) != 3:
                    raise ValueError(f"{mnemonic.upper()} requires 3 arguments")
                ss1 = parse_register(args[0])
                ss2 = parse_register(args[1])
                imm = parse_immediate(args[2], labels, pc, 6, is_relative=True)
                opcode = "0101" if mnemonic == 'beq' else "0110"
                binary_inst = f"{opcode}{ss1}{ss2}{imm}"
                
            elif mnemonic == 'jal':
                # JAL ddd, imm OR JAL imm (defaults to ddd=r1)
                if len(args) == 1:
                    ddd = '001' # default to r1 (ra)
                    imm = parse_immediate(args[0], labels, pc, 9, is_relative=True)
                elif len(args) == 2:
                    ddd = parse_register(args[0])
                    imm = parse_immediate(args[1], labels, pc, 9, is_relative=True)
                else:
                    raise ValueError("JAL requires 1 or 2 arguments")
                binary_inst = f"0111{ddd}{imm}"
                
            elif mnemonic == 'jalr':
                # JALR ddd, ss1, imm
                if len(args) != 3:
                    raise ValueError("JALR requires 3 arguments")
                ddd = parse_register(args[0])
                ss1 = parse_register(args[1])
                imm = parse_immediate(args[2], labels, pc, 6, is_relative=False)
                binary_inst = f"1000{ddd}{ss1}{imm}"
                
            else:
                raise ValueError(f"Unknown instruction: {mnemonic}")
                
            hex_inst = format(int(binary_inst, 2), '04X')
            machine_code.append((pc, hex_inst, raw_line))
            
        except Exception as e:
            print(f"Error on line: '{raw_line}'")
            print(f"Message: {str(e)}")
            sys.exit(1)

    # Write output file
    try:
        with open(output_file, 'w') as f:
            for pc, hex_inst, _ in machine_code:
                f.write(f'{pc} => x"{hex_inst}",\n')
            f.write('others => x"0000"\n')
        print(f"Assembly completed successfully. Output saved to {output_file}")
    except Exception as e:
        print(f"Error writing to output file '{output_file}': {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python assembler.py <input.s> <output.txt>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    assemble(input_file, output_file)
