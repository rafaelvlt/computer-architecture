lw x19, f
lw x20, g
lw x21, h
lw x22, i
lw x23, j
beq x22, x23,soma 
sub x19,x20,x21
bge x0,x0,end

soma: add x19,x20,x21
end:sw x19, f
halt

f: .word 0
g: .word 3
h: .word 2
i: .word 5
j: .word 5


