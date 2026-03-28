module mux_4x1(
	input[31:0]A,
	input[31:0]B,
	input[31:0]C,
	input[31:0]D,
	input[1:0]chave,
	output reg [31:0]Out

);
  always @ (*) 
    begin
	 case (chave)
          2'b00 : Out = A;
          2'b01 : Out = B;
          2'b10 : Out = C;
          2'b11 : Out = D;
      	 endcase
    end
endmodule
