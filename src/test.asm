addi r1, r0, 10
addi r2, r0, 55
addi r3, r0, 0
add r4, r1, r2
sub r4, r2, r1
and r4, r1, r2
or r4, r1, r2
slt r5, r1, r2
sll r6, r1, 2
srl r6, r1, 2





addi r1, r0, 10
addi r2, r0, 55
addi r3, r0, 0
sw r1, 4(r0)
lw r4, 4(r0)




addi r1, r0, 10
addi r2, r0, 25
addi r3, r0, 5
loop:
beq r1, r2, exit 
add r1, r1, r3
j loop
exit:
sw r1, 0(r0)




addi r1, r0, 10
addi r2, r0, 55
addi r3, r0, 5
add r1, r2, r3
sub r4, r1, r5  

addi r1, r0, 5   
addi r2, r0, 10  
addi r3, r0, 1
start:
slt r4, r1, r2
beq r4, r0, end
add r1, r1, r3
j start
end:
sw r1, 0(r0)


