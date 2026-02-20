module DCT_4_8(
    input clk, reset,
    input [143:0] d_in_flat, // 8 words * 18 bits = 144 bits
    output [143:0] d_out_flat // 8 words * 18 bits = 144 bits
);
    wire signed [17:0] d_in [0:7];
    genvar k;
    generate
        for (k = 0; k < 8; k = k + 1) assign d_in[k] = d_in_flat[k*18 +: 18];
    endgenerate

    wire [71:0] s1_t_f, s1_b_f;
    DCT_building_block #(.m(4), .COEFF(362)) bb1 (
        .clk(clk), .reset(reset),
        .top_in_flat({d_in[3], d_in[2], d_in[1], d_in[0]}),
        .bot_in_flat({d_in[7], d_in[6], d_in[5], d_in[4]}),
        .top_out_flat(s1_t_f), .bot_out_flat(s1_b_f)
    );


    wire [35:0] s2_tt, s2_tb, s2_bt, s2_bb;
    DCT_building_block #(.m(2), .COEFF(473)) bb2a (.clk(clk), .reset(reset), .top_in_flat(s1_t_f[35:0]),  .bot_in_flat(s1_t_f[71:36]),  .top_out_flat(s2_tt), .bot_out_flat(s2_tb));
    DCT_building_block #(.m(2), .COEFF(196)) bb2b (.clk(clk), .reset(reset), .top_in_flat(s1_b_f[35:0]),  .bot_in_flat(s1_b_f[71:36]),  .top_out_flat(s2_bt), .bot_out_flat(s2_bb));

    wire signed [17:0] x1, x3, x5, x7, x9, x11, x13, x15;
    DCT_building_block #(.m(1), .COEFF(502)) bb3a (.clk(clk), .reset(reset), .top_in_flat(s2_tt[17:0]), .bot_in_flat(s2_tt[35:18]), .top_out_flat(x1),  .bot_out_flat(x3));
    DCT_building_block #(.m(1), .COEFF(50))  bb3b (.clk(clk), .reset(reset), .top_in_flat(s2_tb[17:0]), .bot_in_flat(s2_tb[35:18]), .top_out_flat(x5),  .bot_out_flat(x7));
    DCT_building_block #(.m(1), .COEFF(425)) bb3c (.clk(clk), .reset(reset), .top_in_flat(s2_bt[17:0]), .bot_in_flat(s2_bt[35:18]), .top_out_flat(x9),  .bot_out_flat(x11));
    DCT_building_block #(.m(1), .COEFF(284)) bb3d (.clk(clk), .reset(reset), .top_in_flat(s2_bb[17:0]), .bot_in_flat(s2_bb[35:18]), .top_out_flat(x13), .bot_out_flat(x15));

    assign d_out_flat = {x15, x13, x11, x9, x7, x5, x3, x1};
endmodule
