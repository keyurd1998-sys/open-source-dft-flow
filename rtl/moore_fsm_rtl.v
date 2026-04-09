module moore_machine (
    input wire clk,
    input wire rst_n,
    input wire x,
    output reg [4:2] y // Outputs Y[4], Y[3], Y[2]
);
(* fsm_encoding = "binary" *)
    // State Encoding
    typedef enum reg [2:0] {
        STATE_A = 3'd0,
        STATE_B = 3'd1,
        STATE_C = 3'd2,
        STATE_D = 3'd3,
        STATE_E = 3'd4,
        STATE_F = 3'd5,
        STATE_G = 3'd6,
        STATE_H = 3'd7
    } state_t;

    state_t current_state, next_state;

    // 1. State Register (Sequential)
    always @(negedge clk or posedge rst_n) begin
        if (rst_n)
            current_state <= STATE_A;
        else
            current_state <= next_state;
    end

    // 2. Next State Logic and Output Logic (Combinational)
    always @(*) begin
        // Default values
        next_state = current_state;
        y = 3'b000;

        case (current_state)
            STATE_A: begin
                if (x == 0) begin next_state = STATE_A; y = 3'b000; end
                else        begin next_state = STATE_G; y = 3'b110; end
            end
            STATE_B: begin
                if (x == 0) begin next_state = STATE_A; y = 3'b000; end
                else        begin next_state = STATE_H; y = 3'b111; end
            end
            STATE_C: begin
                if (x == 0) begin next_state = STATE_F; y = 3'b101; end
                else        begin next_state = STATE_D; y = 3'b011; end
            end
            STATE_D: begin
                if (x == 0) begin next_state = STATE_B; y = 3'b001; end
                else        begin next_state = STATE_A; y = 3'b000; end
            end
            STATE_E: begin
                if (x == 0) begin next_state = STATE_F; y = 3'b101; end
                else        begin next_state = STATE_C; y = 3'b010; end
            end
            STATE_F: begin
                if (x == 0) begin next_state = STATE_H; y = 3'b111; end
                else        begin next_state = STATE_C; y = 3'b010; end
            end
            STATE_G: begin
                if (x == 0) begin next_state = STATE_G; y = 3'b110; end
                else        begin next_state = STATE_B; y = 3'b001; end
            end
            STATE_H: begin
                if (x == 0) begin next_state = STATE_H; y = 3'b111; end
                else        begin next_state = STATE_E; y = 3'b100; end
            end
            default: begin
                next_state = STATE_A;
                y = 3'b000;
            end
        endcase
    end

endmodule
