lw x10, a
lw x11, b
lw x12, m
add x12, x10, x0 
blt x11, x12, soma
bge x0, x0, save

soma: add x12, x10, x11
save: sw x12, m

halt

a: .word 25
b: .word 12
m: .word 0x0000


