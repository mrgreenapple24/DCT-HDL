module DCT_input_buffer(
    input clk, reset, start,
    input [7:0] IN_A, IN_B,
    output [287:0] x_reg_flat,
    output reg ready
);
    reg [3:0] count;
    reg signed [17:0] x_internal [0:15];

    always @(posedge clk) begin
        if (reset) begin
            count <= 0;
            ready <= 0;
        end else begin
            if (start || (count > 0 && count < 8)) begin
                x_internal[count]    <= $signed({IN_A, 8'b0});
                x_internal[15-count] <= $signed({IN_B, 8'b0});

                if (count == 7) begin
                    ready <= 1;
                    count <= 0;
                end else begin
                    count <= count + 1;
                    ready <= 0;
                end
            end else begin
                ready <= 0;
            end
        end
    end

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : pack
            assign x_reg_flat[i*18 +: 18] = x_internal[i];
        end
    endgenerate
endmodule
