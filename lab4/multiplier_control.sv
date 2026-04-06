module multiplier_control (
    input  logic clk,
    input  logic rst_n,

    // Interface com o usuario
    input  logic start,
    output logic done,

    // Interface com o datapath
    output logic load,        // Carrega operandos iniciais
    output logic compute_en   // Executa uma iteracao (add condicional + shift)
);

    // -----------------------------------------------------------------------
    // Definicao dos estados — codificacao one-hot
    // -----------------------------------------------------------------------
    typedef enum logic [3:0] {
        IDLE        = 4'b0001,
        LOAD        = 4'b0010,
        COMPUTE     = 4'b0100,
        DONE        = 4'b1000
    } state_t;

    state_t state, next_state;
    
    // -----------------------------------------------------------------------
    // Contador de iteracoes
    // -----------------------------------------------------------------------
    logic [5:0] count;
    logic       count_en;
    logic       count_rst;
		
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)         count <= '0;
        else if (count_rst) count <= '0;
        else if (count_en)  count <= count + 6'd1;
    end

    // -----------------------------------------------------------------------
    // Registrador de estado
    // -----------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= IDLE;
        else        state <= next_state;
    end
    
    // -----------------------------------------------------------------------
    // Logica de proximo estado
    // -----------------------------------------------------------------------
    always_comb begin
        next_state = state;
        case (state)
            IDLE:        if (start)           next_state = LOAD;
            LOAD:                             next_state = COMPUTE;
        		COMPUTE:     if (count == 6'd31)  next_state = DONE;
                         else                 next_state = COMPUTE;
            DONE:        if (!start)          next_state = IDLE;
            default:                          next_state = IDLE;
        endcase
    end
    
    // -----------------------------------------------------------------------
    // Logica de saida
    // -----------------------------------------------------------------------
    always_comb begin
        // Valores padrao
        load       = 1'b0;
        compute_en = 1'b0;
        done       = 1'b0;
        count_en   = 1'b0;
        count_rst  = 1'b0;

        case (state)
            IDLE: begin
                count_rst = 1'b1; // Mantem o contador em 0 enquanto ocioso
            end

            LOAD: begin
                load      = 1'b1; // Carrega operandos no datapath
                count_rst = 1'b1; // Reseta o contador
            end

            COMPUTE: begin
								compute_en = 1'b1;
                count_en = 1'b1;
            end

            DONE: begin
                done = 1'b1;
            end

            default: ;
        endcase
    end
    
endmodule