module mealy_fsm (
    input  wire clk,
    input  wire reset,
    input  wire X,
    output reg [4:0] Y
);
(* fsm_encoding = "binary" *)
    // State encoding using parameters
    parameter A = 3'd0,
              B = 3'd1,
              C = 3'd2,
              D = 3'd3,
              E = 3'd4,
              F = 3'd5,
              G = 3'd6,
              H = 3'd7;

    reg [2:0] current_state, next_state;

    // State register
    always @(negedge clk or posedge reset) begin
        if (reset)
            current_state <= A;
        else
            current_state <= next_state;
    end

    // Next state + Output logic (Mealy)
    always @(*) begin
        // Default values
        next_state = current_state;
        Y = 5'b00000;

        case (current_state)

            A: begin
                if (X == 0) begin next_state = A; Y = 5'b00011; end
                else        begin next_state = G; Y = 5'b10011; end
            end

            B: begin
                if (X == 0) begin next_state = A; Y = 5'b10100; end
                else        begin next_state = H; Y = 5'b01111; end
            end

            C: begin
                if (X == 0) begin next_state = H; Y = 5'b01010; end
                else        begin next_state = E; Y = 5'b00101; end
            end

            D: begin
                if (X == 0) begin next_state = B; Y = 5'b11111; end
                else        begin next_state = A; Y = 5'b11100; end
            end

            E: begin
                if (X == 0) begin next_state = D; Y = 5'b00110; end
                else        begin next_state = H; Y = 5'b10000; end
            end

            F: begin
                if (X == 0) begin next_state = H; Y = 5'b11001; end
                else        begin next_state = C; Y = 5'b01000; end
            end

            G: begin
                if (X == 0) begin next_state = D; Y = 5'b10001; end
                else        begin next_state = B; Y = 5'b00001; end
            end

            H: begin
                if (X == 0) begin next_state = H; Y = 5'b01001; end
                else        begin next_state = F; Y = 5'b00000; end
            end

            default: begin
                next_state = A;
                Y = 5'b00000;
            end

        endcase
    end

endmodule
