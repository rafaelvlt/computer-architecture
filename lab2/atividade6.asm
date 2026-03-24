addi x5, x0, 1 # começa com o led do pino 2 ligado
addi x6, x0, 0b10000000 # registrador para comparação de final

# lê o pino 8 e checka se é HIGH
loop:
    lb x10, 1026(x0) 
    andi x10, x10, 0x1 
    beq x10, x0, off # caso seja low, mantém
# caso for pressionado, dá shift left no port para ligar o próx led
on: 
    slli x5, x5, 1
    beq x5, x6, fim # caso passar do led 7, dá halt no programa
    sb x5, 1029(x0) # caso for led 7< carrega no portd para ligar os leds
    jal x0, loop
off:
    sb x5, 1029(x0) # mantém o led ligado
    jal x0, loop

fim:
    halt
