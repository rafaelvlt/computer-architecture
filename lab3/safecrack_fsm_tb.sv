`timescale 1ns / 1ps

module safecrack_fsm_tb;

  // -------------------------------------------------------------------------
  // Sinais de estimulo e observacao
  // -------------------------------------------------------------------------
  logic       clk;
  logic       rst_n;
  logic [3:0] btn;
  logic       unlocked;

  // -------------------------------------------------------------------------
  // Instancia do DUT (Device Under Test)
  // -------------------------------------------------------------------------
  safecrack_fsm dut (
      .clk   (clk),
      .rst_n (rst_n),
      .btn   (btn),
      .unlocked  (unlocked)
  );

  // -------------------------------------------------------------------------
  // Geracao de clock: periodo de 20ns -> 50 MHz
  // -------------------------------------------------------------------------
  initial clk = 0;
  always #10 clk = ~clk;

  // -------------------------------------------------------------------------
  // Task: pressiona o botao por alguns ciclos e solta
  //   - btn: invertemos dos pressionados para se adequar a placa ativa em baixo
  //   - pressed: pressionados de fato
  //   - hold_cycles: quantos ciclos o botao fica pressionado
  // -------------------------------------------------------------------------
  task press_button(input logic [3:0] pressed, input int hold_cycles);
    @(negedge clk);
    btn = ~pressed;  //Inverte para facilitar nossa vida      
    repeat (hold_cycles) @(posedge clk);
    @(negedge clk);
    btn = 4'b1111;  // Solta
    repeat (3) @(posedge clk);  // Aguarda estabilizar
  endtask

  // -------------------------------------------------------------------------
  // Task: verifica o estado do Safecrack e imprime resultado
  // -------------------------------------------------------------------------
  task check_state(input logic [4:0] expected, input string msg);
    @(negedge clk);
    if (dut.current_state === expected)
      $display("[PASS] %s | current_state = 5'b%05b", msg, dut.current_state);
    else
      $display(
          "[FAIL] %s | esperado = 5'b%05b, obtido = 5'b%05b", msg, expected, dut.current_state
      );
    $display("unlocked = %b", unlocked);
  endtask

  task reset_state();
    @(negedge clk);
    rst_n = 1'b0;
    repeat (3) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);
    check_state(5'b00001, "Apos reset -> START");
  endtask

  // -------------------------------------------------------------------------
  // Sequencia de testes
  // -------------------------------------------------------------------------
  initial begin
    // Dump de formas de onda para visualizacao no GTKWave
    $dumpfile("safecrack.vcd");
    $dumpvars(0, safecrack_fsm_tb);

    // Condicao inicial
    rst_n = 1'b1;
    btn   = 4'b1111;  // Botao solto (ativo baixo, entao 1 = solto)

    // ------------------------------------------------------------------
    // Teste 1: Reset
    // ------------------------------------------------------------------
    $display("\n=== Teste 1: Reset ===");
    reset_state();

    // ------------------------------------------------------------------
    // Teste 2: Avanca START -> E1 -> E2 -> E3 -> OPEN -> START (ciclo completo)
    // ------------------------------------------------------------------
    $display("\n=== Teste 2: Ciclo completo de estados ===");
    press_button(4'b0001, 2);
    check_state(5'b00010, "Azul pressionado");

    press_button(4'b0010, 2);
    check_state(5'b00100, "Amarelo pressionado");

    press_button(4'b0010, 2);
    check_state(5'b01000, "Amarelo pressionado x2");

    press_button(4'b1000, 2);
    check_state(5'b10000, "Vermelho pressionado e cofre aberto");
    reset_state();
    // ------------------------------------------------------------------
    // Teste 3: Segurar o botao nao deve avancar mais de 1 estado
    // ------------------------------------------------------------------
    $display("\n=== Teste 3: Botao segurado (nao deve avancar mais de 1x) ===");
    press_button(4'b0001, 20);  // Segura por 20 ciclos
    check_state(5'b00010, "Botao segurado 20 ciclos -> apenas azul");
    reset_state();
    // ------------------------------------------------------------------
    // Teste 4: Reset durante operacao
    // ------------------------------------------------------------------
    $display("\n=== Teste 4: Reset durante operacao ===");
    press_button(4'b0001, 2);
    check_state(5'b00010, "Azul pressionado");

    press_button(4'b0010, 2);
    check_state(5'b00100, "Amarelo pressionado");

    rst_n = 1'b0;
    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);
    check_state(5'b00001, "Reset em E2 -> volta para START");
    reset_state();
    // ------------------------------------------------------------------
    // Teste 5: Avanca START -> E1 -> E2 -> START(ERRO NA SEQUENCIA)
    // ------------------------------------------------------------------
    $display("\n=== Teste 5: Erro na sequencia ===");
    press_button(4'b0001, 2);
    check_state(5'b00010, "azul pressionado");

    press_button(4'b0010, 2);
    check_state(5'b00100, "Amarelo pressionado");

    press_button(4'b0100, 2);
    check_state(5'b00001, "senha incorreta");
    reset_state();
    // ------------------------------------------------------------------
    // Teste 6: Avanca START -> E1 -> E2 -> START(MULTIPLOS BOTOES PRESSIONADOS)
    // ------------------------------------------------------------------
    $display("\n=== Teste 6: Múltiplos botoes pressionados ===");
    press_button(4'b0001, 2);
    check_state(5'b00010, "azul pressionado");

    press_button(4'b0010, 2);
    check_state(5'b00100, "Amarelo pressionado");

    press_button(4'b1001, 2);
    check_state(5'b00001, "MULTIPLOS BOTOES PRESSIONADOS");
    reset_state();
    $display("\n=== Simulacao concluida ===\n");
    $finish;


  end

endmodule
