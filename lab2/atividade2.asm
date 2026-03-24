lw x10,a
lw x11,b
lw x12,m

blt x11,x12,soma #if b<m:soma
sub x12,x10,x11 #else:m=a-b
bge x0,x0,save

soma:add x12,x10,x11 #soma:m=a+b
save:sw x12,m #salva o resultado

halt

a: .word 25
b: .word -24
m: .word 0

#a=15, b=-6, m=9(x12/a3[00000009])
#a=14, b=7, m=7 (x12/a3[00000007])
#a=25, b=-24, m=1(x12/a3[00000001])
