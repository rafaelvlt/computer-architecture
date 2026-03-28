module safecrack_fsm (
    input  logic       clk,
    input  logic       rst_n,    // ativa em nivel baixo
    input  logic [3:0] btn,      // botao
    output logic       unlocked  // led
);

  typedef enum logic [4:0] {
    START = 5'b00001,  // Estado inicial
    E1    = 5'b00010,  // azul pressionado
    E2    = 5'b00100,  // 1º amarelo pressionado
    E3    = 5'b01000,  // 2º amarelo pressionado
    OPEN  = 5'b10000   // vermelho pressionado e unlock
  } state_safecrack;

  state_safecrack current_state, next_state;

  logic [3:0] btn_active;
  logic [3:0] btn_prev;
  logic [3:0] btn_rise;

  assign btn_active = ~btn;  // invertendo o vetor
  assign btn_rise   = btn_active & ~btn_prev;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) btn_prev <= 4'b0000;
    else btn_prev <= btn_active;
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) current_state <= START;
    else current_state <= next_state;
  end

  always_comb begin
    next_state = current_state;
    unlocked   = 0;

    unique case (current_state)
      START: begin
        if (btn_rise == 4'b0001) next_state = E1;
        else if (btn_rise != 4'b0000) next_state = START;
      end
      E1: begin
        if (btn_rise == 4'b0010) next_state = E2;
        else if (btn_rise != 4'b0000) next_state = START;
      end
      E2: begin
        if (btn_rise == 4'b0010) next_state = E3;
        else if (btn_rise != 4'b0000) next_state = START;
      end
      E3: begin
        if (btn_rise == 4'b1000) next_state = OPEN;
        else if (btn_rise != 4'b0000) next_state = START;
      end
      OPEN: begin
        unlocked = 1;
      end

      default: next_state = START;
    endcase
  end
endmodule
