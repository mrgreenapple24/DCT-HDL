module stage_1(
    input clk,
    input reset,
    input [287:0] x_in_flat,      // 16 words * 18 bits
    output reg [143:0] y_up_flat, // 8 words * 18 bits
    output reg [143:0] y_lo_flat  // 8 words * 18 bits
);

    wire signed [17:0] x_in [0:15];

    genvar k;
    generate
        for (k = 0; k < 16; k = k + 1) begin : unpack
            assign x_in[k] = x_in_flat[k*18 +: 18];
        end
    endgenerate

    integer i;
    always @(posedge clk) begin
        if (reset) begin
            y_up_flat <= 0;
            y_lo_flat <= 0;
        end else begin
            for (i = 0; i < 8; i = i + 1) begin
                y_up_flat[i*18 +: 18] <= x_in[i] + x_in[15-i];
                y_lo_flat[i*18 +: 18] <= x_in[i] - x_in[15-i];
            end
        end
    end
endmodule
