// =============================================================================
// sc_control.sv
// Main Control Unit - single-cycle RISC-V (Section 4.4 - Patterson & Hennessy)
//
// Decodes the 7-bit opcode and asserts control signals for the datapath.
//
// Supported instructions:
//   R-type  (0110011): add, sub, and, or, slt
//   I-type  (0000011): lw
//   S-type  (0100011): sw
//   B-type  (1100011): beq
//
// Control signal summary:
//
//   Signal    | R-type | lw | sw | beq
//   ----------|--------|----|----|-----
//   ALUSrc    |   0    |  1 |  1 |  0    0=reg, 1=imm
//   MemtoReg  |   0    |  1 |  - |  -    0=ALU, 1=mem
//   RegWrite  |   1    |  1 |  0 |  0
//   MemRead   |   0    |  1 |  0 |  0
//   MemWrite  |   0    |  0 |  1 |  0
//   Branch    |   0    |  0 |  0 |  1
//   ALUOp[1]  |   1    |  0 |  0 |  0
//   ALUOp[0]  |   0    |  0 |  0 |  1
//
//   ALUOp encoding:
//     2'b00 = Load/Store (force ADD)
//     2'b01 = Branch     (force SUB)
//     2'b10 = R-type     (ALU Control decodes Funct3/Funct7)
// =============================================================================
`timescale 1ns / 1ps

module sc_control (
    input  logic [6:0] Opcode,
    output logic       ALUSrc,
    output logic       MemtoReg,
    output logic       RegWrite,
    output logic       MemRead,
    output logic       MemWrite,
    output logic       Branch,
    output logic [1:0] ALUOp
);
    localparam R_TYPE = 7'b0110011; // add, sub, and, or, slt
    localparam LOAD   = 7'b0000011; // lw
    localparam STORE  = 7'b0100011; // sw
    localparam BRANCH = 7'b1100011; // beq

    always_comb begin
        // Valores padrão seguros ? evitam latches e garantem que opcodes
        // desconhecidos não causem efeitos colaterais (sem escrita em
        // memória ou registradores).
        ALUSrc   = 1'b0;
        MemtoReg = 1'b0;
        RegWrite = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        Branch   = 1'b0;
        ALUOp    = 2'b00;

        case (Opcode)

            R_TYPE: begin
                // add, sub, and, or, slt
                // Operandos vêm dos registradores (ALUSrc = 0)
                // Resultado da ALU vai para o registrador destino (MemtoReg = 0)
                // Escreve no banco de registradores (RegWrite = 1)
                // Não acessa memória de dados
                // ALUOp = 10: sc_alu_ctrl decodifica Funct3/Funct7
                ALUSrc   = 1'b0;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                Branch   = 1'b0;
                ALUOp    = 2'b10;
            end

            LOAD: begin
                // lw  ?  load word
                // Segundo operando da ALU é o imediato (offset) (ALUSrc = 1)
                // Dado lido da memória vai para o registrador destino (MemtoReg = 1)
                // Escreve no banco de registradores (RegWrite = 1)
                // Lê da memória de dados (MemRead = 1)
                // ALUOp = 00: ALU sempre soma (calcula endereço base + offset)
                ALUSrc   = 1'b1;
                MemtoReg = 1'b1;
                RegWrite = 1'b1;
                MemRead  = 1'b1;
                MemWrite = 1'b0;
                Branch   = 1'b0;
                ALUOp    = 2'b00;
            end

            STORE: begin
                // sw  ?  store word
                // Segundo operando da ALU é o imediato (offset) (ALUSrc = 1)
                // MemtoReg não importa (nenhum registrador é escrito)
                // Não escreve no banco de registradores (RegWrite = 0)
                // Escreve na memória de dados (MemWrite = 1)
                // ALUOp = 00: ALU sempre soma (calcula endereço base + offset)
                ALUSrc   = 1'b1;
                MemtoReg = 1'b0; // don't care; mantido em 0 por segurança
                RegWrite = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b1;
                Branch   = 1'b0;
                ALUOp    = 2'b00;
            end

            BRANCH: begin
                // beq  ?  branch if equal
                // Operandos vêm dos registradores (ALUSrc = 0)
                // MemtoReg não importa (nenhum registrador é escrito)
                // Não escreve no banco de registradores (RegWrite = 0)
                // Não acessa memória de dados
                // Branch = 1: habilita desvio se ALU indicar igualdade (Zero=1)
                // ALUOp = 01: ALU sempre subtrai (rs1 - rs2) para testar igualdade
                ALUSrc   = 1'b0;
                MemtoReg = 1'b0; // don't care; mantido em 0 por segurança
                RegWrite = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                Branch   = 1'b1;
                ALUOp    = 2'b01;
            end

            default: ;
        endcase
    end

endmodule
