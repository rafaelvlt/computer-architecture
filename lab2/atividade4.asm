addi x5, x0, 32 #endereço inicial string
addi x6, x0, 1024 #endereço do monitor

loop:
    lb x10, 0(x5)#pega o char atual
    beq x10, x0, fim #se char'\0' termina 
    sb x10, 0(x6)#manda char para o monitor
    addi x5, x5, 1 #passa para o proxio char da string
    beq x0, x0, loop #retorna para o começo do loop


fim:
    halt

str1: .string "Hello World"
