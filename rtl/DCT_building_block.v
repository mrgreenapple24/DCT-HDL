module DCT_building_block #(
    parameter m = 1,
    parameter integer COEFF = 256
)(
    input  clk, reset,
    input  signed [(m*18)-1:0] top_in_flat,
    input  signed [(m*18)-1:0] bot_in_flat,
    output reg signed [(m*18)-1:0] top_out_flat,
    output reg signed [(m*18)-1:0] bot_out_flat
);
    wire signed [17:0] top_in [0:m-1];
    wire signed [17:0] bot_in [0:m-1];
    wire signed [17:0] inter_top [0:m-1];
    wire signed [17:0] inter_bot [0:m-1];

    genvar k;
    generate
        for (k = 0; k < m; k = k + 1) begin : vector_math
            assign top_in[k] = top_in_flat[k*18 +: 18];
            assign bot_in[k] = bot_in_flat[k*18 +: 18];

            // Python: inter_top = top - bot[::-1]
            // We subtract the mirrored index for the top branch
            assign inter_top[k] = top_in[k] - bot_in[m-1-k];

            // Python: inter_bot = coeff * original_bot
            // Use a temporary 36-bit wire to handle the Q.8 multiplication
            wire signed [35:0] prod = bot_in[k] * $signed({1'b0, COEFF[16:0]});
            assign inter_bot[k] = prod[25:8];
        end
    endgenerate

    integer i;
    always @(posedge clk) begin
        if (reset) begin
            top_out_flat <= 0;
            bot_out_flat <= 0;
        end else begin
            for (i = 0; i < m; i = i + 1) begin
                // Python: out_top = inter_top + inter_bot
                // Python: out_bot = inter_top - inter_bot
                top_out_flat[i*18 +: 18] <= inter_top[i] + inter_bot[i];
                bot_out_flat[i*18 +: 18] <= inter_top[i] - inter_bot[i];
            end
        end
    end
endmodule
