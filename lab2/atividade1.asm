lw x10, a 
lw x11, b 
lw x12, m
add x12, x10, x0 #m=a
blt x11, x12, soma #b<m?
bge x0, x0, save

soma: add x12, x10, x11 #m=a+b
save: sw x12, m

halt

a: .word 25
b: .word 12
m: .word 0x0000


#se a=6 b=15 m=6
#se a=14 b=7 m=21(0x15)
#se a=25 b=12 m=37(0x25)
