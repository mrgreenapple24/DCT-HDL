module DCT_2_8(
    input clk, reset,
    input [143:0] d_in_flat, // 8 words * 18 bits
    output [143:0] d_out_flat
);
    wire signed [17:0] d_in [0:7];
    genvar k;
    generate
        for (k = 0; k < 8; k = k + 1) assign d_in[k] = d_in_flat[k*18 +: 18];
    endgenerate

    // Stage 2 Butterfly
    reg signed [17:0] s2_upper [0:3];
    reg signed [17:0] s2_lower [0:3];

    always @(posedge clk) begin
        if (reset) begin
            for (integer j = 0; j < 4; j = j + 1) begin
                s2_upper[j] <= 18'sd0;
                s2_lower[j] <= 18'sd0;
            end
        end else begin
            for (integer j = 0; j < 4; j = j + 1) begin
                s2_upper[j] <= d_in[j] + d_in[7-j];
                s2_lower[j] <= d_in[j] - d_in[7-j];
            end
        end
    end

    // Path A: DCT-4_4 (Lower branch)
    wire [35:0] bb_pi4_t_o, bb_pi4_b_o; // 2 words * 18 bits = 36 bits
    DCT_building_block #(.m(2), .COEFF(362)) bb_pi4 (
        .clk(clk), .reset(reset),
        .top_in_flat({s2_lower[1], s2_lower[0]}), // Fixed order for 18-bit
        .bot_in_flat({s2_lower[3], s2_lower[2]}),
        .top_out_flat(bb_pi4_t_o), .bot_out_flat(bb_pi4_b_o)
    );

    wire signed [17:0] x2, x6, x10, x14;
    DCT_building_block #(.m(1), .COEFF(473)) bb_pi8  (.clk(clk), .reset(reset), .top_in_flat(bb_pi4_t_o[17:0]), .bot_in_flat(bb_pi4_t_o[35:18]), .top_out_flat(x2), .bot_out_flat(x6));
    DCT_building_block #(.m(1), .COEFF(196)) bb_3pi8 (.clk(clk), .reset(reset), .top_in_flat(bb_pi4_b_o[17:0]), .bot_in_flat(bb_pi4_b_o[35:18]), .top_out_flat(x10), .bot_out_flat(x14));

    // Path B: DCT-2_4 (Upper branch)
    reg signed [17:0] x0_reg, x8_reg;
    wire signed [17:0] x4, x12;
    reg signed [17:0] s3_u0, s3_u1;

    always @(posedge clk) begin
        if (reset) begin
            s3_u0 <= 18'sd0;
            s3_u1 <= 18'sd0;
        end else begin
            s3_u0 <= s2_upper[0] + s2_upper[3];
            s3_u1 <= s2_upper[1] + s2_upper[2];
        end
    end

    // Path for X4 and X12
    DCT_building_block #(.m(1), .COEFF(362)) bb_x4 (
        .clk(clk), .reset(reset),
        .top_in_flat(s2_upper[0] - s2_upper[3]),
        .bot_in_flat(s2_upper[1] - s2_upper[2]),
        .top_out_flat(x4), .bot_out_flat(x12)
    );

    // Final X0 and X8 Logic
    always @(posedge clk) begin
        if (reset) begin
            x0_reg <= 18'sd0;
            x8_reg <= 18'sd0;
        end else begin
            x0_reg <= s3_u0 + s3_u1;
            x8_reg <= s3_u0 - s3_u1;
        end
    end

    assign d_out_flat = {x14, x10, x6, x2, x12, x4, x8_reg, x0_reg};

    /*
    always @(posedge clk) begin
        if (!reset) begin
            $display("[DCT_2_8] smth1: %f, smth2: %f",
                $itor($signed(bb_pi4_t_o[17:0]))/256.0,
                $itor($signed(bb_pi4_t_o[35:18]))/256.0
            );
        end
    end

    */

endmodule
