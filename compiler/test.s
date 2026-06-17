# Test Assembly File for Custom RISC-V Assembler

start:
    LI r1, 10           # Load immediate 10 into r1
    LI r2, 20           # Load immediate 20 into r2
    ADD r3, r1, r2      # r3 = r1 + r2
    SUB r4, r2, r1      # r4 = r2 - r1
    ADDI r5, r3, 5      # r5 = r3 + 5
    
    SW r3, 0(r0)        # Store r3 at address 0
    LW r6, 0(r0)        # Load from address 0 into r6
    
loop:
    BEQ r6, r0, end     # Branch to end if r6 == 0
    ADDI r6, r6, -1     # Decrement r6
    JAL r7, loop        # Jump and link to loop
    
end:
    NOP
    JALR r0, r1, 0      # Return (assuming r1 holds return address)
