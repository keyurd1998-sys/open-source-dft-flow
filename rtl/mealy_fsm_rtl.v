module mealy_fsm (
    input  clk,
    input  reset,
    input  X,
    output reg [4:0] Y
);
(* fsm_encoding = "binary" *)
    // Using reg [2:0] and localparam to force 3-bit binary encoding
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

    // --- Next State & Output Combinational Logic ---
    always @(*) begin
        // Default assignments to prevent latches
        next_state = current_state;
        Y = 5'b00000;

        case (current_state)
            STATE_A: begin
                next_state = (X == 1'b0) ? STATE_A : STATE_G;
                Y          = (X == 1'b0) ? 5'b00011 : 5'b10011;
            end
            STATE_B: begin
                next_state = (X == 1'b0) ? STATE_A : STATE_H;
                Y          = (X == 1'b0) ? 5'b10100 : 5'b01111;
            end
            STATE_C: begin
                next_state = (X == 1'b0) ? STATE_H : STATE_E;
                Y          = (X == 1'b0) ? 5'b01010 : 5'b00101;
            end
            STATE_D: begin
                next_state = (X == 1'b0) ? STATE_B : STATE_A;
                Y          = (X == 1'b0) ? 5'b11111 : 5'b11100;
            end
            STATE_E: begin
                next_state = (X == 1'b0) ? STATE_D : STATE_H;
                Y          = (X == 1'b0) ? 5'b00110 : 5'b10000;
            end
            STATE_F: begin
                next_state = (X == 1'b0) ? STATE_H : STATE_C;
                Y          = (X == 1'b0) ? 5'b11001 : 5'b01000;
            end
            STATE_G: begin
                next_state = (X == 1'b0) ? STATE_D : STATE_B;
                Y          = (X == 1'b0) ? 5'b10101 : 5'b00001;
            end
            STATE_H: begin
                next_state = (X == 1'b0) ? STATE_H : STATE_F;
                Y          = (X == 1'b0) ? 5'b01101 : 5'b00000;
            end
            default: begin
                next_state = STATE_A;
                Y = 5'b00000;
            end
        endcase
    end

endmodule
