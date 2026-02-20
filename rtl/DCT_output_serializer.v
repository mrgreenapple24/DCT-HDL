module output_serializer(
    input clk,
    input reset,
    input data_valid,
    input [287:0] all_results_flat, // 16 coefficients * 18 bits = 288 bits
    output reg signed [17:0] OUT_A,
    output reg signed [17:0] OUT_B,
    output reg [3:0] IDX_A,
    output reg [3:0] IDX_B,
    output reg out_en
);
    reg [2:0] step;
    wire signed [17:0] results [0:15];

    // Unpack the 18-bit coefficients
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : unpack
            assign results[i] = all_results_flat[i*18 +: 18];
        end
    endgenerate

    always @(posedge clk) begin
        if (reset) begin
            step <= 0;
            out_en <= 0;
            OUT_A <= 0; OUT_B <= 0;
            IDX_A <= 0; IDX_B <= 0;
        end else if (data_valid) begin
            out_en <= 1;
            step <= 0;
            // First pair: X0 and X8 from core_even
            OUT_A <= results[0]; OUT_B <= results[1];
            IDX_A <= 4'd0;       IDX_B <= 4'd8;
        end else if (out_en) begin
            if (step < 7) begin
                step <= step + 1;
                case(step + 3'd1)
                    // --- Even Path Mapping (Indices 0-7 of flat bus) ---
                    3'd1: begin OUT_A <= results[2];  OUT_B <= results[3];  IDX_A <= 4'd4;  IDX_B <= 4'd12; end
                    3'd2: begin OUT_A <= results[4];  OUT_B <= results[5];  IDX_A <= 4'd2;  IDX_B <= 4'd6;  end
                    3'd3: begin OUT_A <= results[6];  OUT_B <= results[7];  IDX_A <= 4'd10; IDX_B <= 4'd14; end

                    // --- Odd Path Mapping (Indices 8-15 of flat bus) ---
                    3'd4: begin OUT_A <= results[8];  OUT_B <= results[9];  IDX_A <= 4'd1;  IDX_B <= 4'd3;  end
                    3'd5: begin OUT_A <= results[10]; OUT_B <= results[11]; IDX_A <= 4'd5;  IDX_B <= 4'd7;  end
                    3'd6: begin OUT_A <= results[12]; OUT_B <= results[13]; IDX_A <= 4'd9;  IDX_B <= 4'd11; end
                    3'd7: begin OUT_A <= results[14]; OUT_B <= results[15]; IDX_A <= 4'd13; IDX_B <= 4'd15; end
                    default: ;
                endcase
            end else begin
                out_en <= 0;
                step <= 0;
            end
        end
    end
endmodule
