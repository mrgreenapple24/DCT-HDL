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

    genvar k;
    generate
        for (k = 0; k < m; k = k + 1) begin : unpack
            assign top_in[k] = top_in_flat[k*18 +: 18];
            assign bot_in[k] = bot_in_flat[k*18 +: 18];
        end
    endgenerate

    integer i;
    reg signed [17:0] s_d;
    reg signed [35:0] prod;

    always @(posedge clk) begin
        if (reset) begin
            top_out_flat <= 0;
            bot_out_flat <= 0;
        end else begin
            for (i = 0; i < m; i = i + 1) begin
                s_d  = top_in[i] - bot_in[m-1-i];
                prod = bot_in[m-1-i] * $signed(COEFF[17:0]);

                top_out_flat[i*18 +: 18] <= s_d + prod[25:8];
                bot_out_flat[i*18 +: 18] <= s_d - prod[25:8];
            end
        end
    end
endmodule
