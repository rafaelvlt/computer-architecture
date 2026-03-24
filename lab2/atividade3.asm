#carrega os valores genericos declarados
lw x19, f
lw x20, g
lw x21, h
lw x22, i
lw x23, j

beq x22, x23,soma #(i==j)?
sub x19,x20,x21 # else: f=g-h
bge x0,x0,end #pula para o fim

soma: add x19,x20,x21 #if true: f=g+h
end:sw x19, f #salva f
halt

#valores genericos para f,g,h,i,j
f: .word 0
g: .word 3
h: .word 2
i: .word 5
j: .word 5
