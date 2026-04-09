module moore_fsm (
    input  clk,
    input  reset,
    input  X,
    output reg [2:0] Y
);

    // Attribute to force 3-bit binary encoding in Yosys/Fault
    (* fsm_encoding = "binary" *)
    reg [2:0] current_state;
    reg [2:0] next_state;

    localparam STATE_A = 3'b000;
    localparam STATE_B = 3'b001;
    localparam STATE_C = 3'b010;
    localparam STATE_D = 3'b011;
    localparam STATE_E = 3'b100;
    localparam STATE_F = 3'b101;
    localparam STATE_G = 3'b110;
    localparam STATE_H = 3'b111;

    // --- State Register ---
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= STATE_A;
        else
            current_state <= next_state;
    end

    // --- Next State Logic ---
    always @(*) begin
        case (current_state)
            STATE_A: next_state = (X == 1'b0) ? STATE_A : STATE_G;
            STATE_B: next_state = (X == 1'b0) ? STATE_A : STATE_H;
            STATE_C: next_state = (X == 1'b0) ? STATE_F : STATE_D;
            STATE_D: next_state = (X == 1'b0) ? STATE_B : STATE_A;
            STATE_E: next_state = (X == 1'b0) ? STATE_F : STATE_C;
            STATE_F: next_state = (X == 1'b0) ? STATE_H : STATE_C;
            STATE_G: next_state = (X == 1'b0) ? STATE_G : STATE_B;
            STATE_H: next_state = (X == 1'b0) ? STATE_H : STATE_E;
            default: next_state = STATE_A;
        endcase
    end

    // --- Output Logic ---
    // Note: To match your table exactly, Y is determined by State and Input X.
    always @(*) begin
        case (current_state)
            STATE_A: Y = (X == 1'b0) ? 3'b000 : 3'b110;
            STATE_B: Y = (X == 1'b0) ? 3'b000 : 3'b111;
            STATE_C: Y = (X == 1'b0) ? 3'b101 : 3'b011;
            STATE_D: Y = (X == 1'b0) ? 3'b001 : 3'b000;
            STATE_E: Y = (X == 1'b0) ? 3'b101 : 3'b010;
            STATE_F: Y = (X == 1'b0) ? 3'b111 : 3'b010;
            STATE_G: Y = (X == 1'b0) ? 3'b110 : 3'b001;
            STATE_H: Y = (X == 1'b0) ? 3'b111 : 3'b100;
            default: Y = 3'b000;
        endcase
    end

endmodule
