`timescale 1ns / 1ps
module tb_mux4x1;

  reg  [31:0] a;
  reg  [31:0] b;
  reg  [31:0] c;
  reg  [31:0] d;
  reg  [ 1:0] key;
  wire [31:0] saida;

  mux_4x1 uut (
      .Out(saida),
      .A(a),
      .B(b),
      .C(c),
      .D(d),
      .chave(key)
  );

  initial begin
    $monitor($time, "a = %h | b = %h | c = %h | d = %h | key = %b | saida = %h", a, b, c, d, key,
             saida);
    //teste 1
    #10 a = 32'hAAAAAAAA;  //mais enxuto apresentar o numero em hexadecimal
    b = 32'hBBBBBBBB;
    c = 32'hCCCCCCCC;
    d = 32'hDDDDDDDD;
    for (key = 0; key != 2'b11; key++) #10;
    #10;

    //teste 2
    #10 a = 32'hABABABAB;
    b = 32'hBCBCBCBC;
    c = 32'hCDCDCDCD;
    d = 32'hDADADADA;
    for (key = 0; key != 2'b11; key++) #10;
    #10;

    //teste 3
    #10 a = 32'hA0000000;
    b = 32'hB1111111;
    c = 32'hC2222222;
    d = 32'hD3333333;
    for (key = 0; key != 2'b11; key++) #10;
    #10;

    $stop;

  end
endmodule
