lw x10,a
lw x11,b
lw x12,m

blt x11,x12,soma
sub x12,x10,x11
bge x0,x0,save

soma:add x12,x10,x11
save:sw x12,m

halt

a: .word 25
b: .word -24
m: .word 0
