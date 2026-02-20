module DCT(
    input clk,
    input reset,
    input start,
    input [7:0] INPUT_A,
    input [7:0] INPUT_B,
    output signed [17:0] OUTPUT_A,
    output signed [17:0] OUTPUT_B,
    output [3:0] INDEX_A,
    output [3:0] INDEX_B,
    output output_en
);

    wire [287:0] x_buf_flat;
    wire buf_ready;

    DCT_input_buffer input_buf (
        .clk(clk),
        .reset(reset),
        .start(start),
        .IN_A(INPUT_A),
        .IN_B(INPUT_B),
        .x_reg_flat(x_buf_flat),
        .ready(buf_ready)
    );

    wire [143:0] s1_up, s1_lo;
    reg s1_ready;

    stage_1 stage1_inst (
        .clk(clk),
        .reset(reset),
        .x_in_flat(x_buf_flat),
        .y_up_flat(s1_up),
        .y_lo_flat(s1_lo)
    );

    always @(posedge clk) begin
        if (reset) s1_ready <= 0;
        else       s1_ready <= buf_ready;
    end

    wire [143:0] res_even, res_odd;

    DCT_2_8 core_even (
        .clk(clk), .reset(reset),
        .d_in_flat(s1_up),
        .d_out_flat(res_even)
    );

    DCT_4_8 core_odd (
        .clk(clk), .reset(reset),
        .d_in_flat(s1_lo),
        .d_out_flat(res_odd)
    );

    reg [5:0] done_pipe;
    always @(posedge clk) begin
        if (reset) done_pipe <= 0;
        else       done_pipe <= {done_pipe[4:0], s1_ready};
    end

    // 5. Output Serializer
    output_serializer serializer_inst (
        .clk(clk), .reset(reset),
        .data_valid(done_pipe[5]),
        .all_results_flat({res_odd, res_even}),
        .OUT_A(OUTPUT_A), .OUT_B(OUTPUT_B),
        .IDX_A(INDEX_A), .IDX_B(INDEX_B),
        .out_en(output_en)
    );
endmodule
