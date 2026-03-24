
addi x5, x0, 42 # 42 é o ascii de *

loop:
    lb x10, 1025(x0) # dá load do teclado
    beq x5, x10, fim # se o valor loadado for 42(*) ele vai pro fim e para
    sb x10, 1024(x0) # se nao escreve
jal x0, loop #loop

fim:
    halt 

