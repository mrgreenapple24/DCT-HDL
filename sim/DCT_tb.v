`timescale 1ns / 1ps

module DCT_tb();
    reg clk;
    reg reset;
    reg start;
    reg [7:0] INPUT_A;
    reg [7:0] INPUT_B;

    wire signed [17:0] OUTPUT_A;
    wire signed [17:0] OUTPUT_B;
    wire [3:0] INDEX_A;
    wire [3:0] INDEX_B;
    wire output_en;

    reg [7:0] test_data [0:15];

    DCT uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .INPUT_A(INPUT_A),
        .INPUT_B(INPUT_B),
        .OUTPUT_A(OUTPUT_A),
        .OUTPUT_B(OUTPUT_B),
        .INDEX_A(INDEX_A),
        .INDEX_B(INDEX_B),
        .output_en(output_en)
    );

    always #5 clk = ~clk;

    initial begin
        test_data[0]=1;  test_data[1]=3;  test_data[2]=5;  test_data[3]=7;
        test_data[4]=9;  test_data[5]=17; test_data[6]=19; test_data[7]=21;
        test_data[8]=22; test_data[9]=18; test_data[10]=18; test_data[11]=16;
        test_data[12]=8; test_data[13]=6;  test_data[14]=4;  test_data[15]=2;

        clk = 0;
        reset = 1;
        start = 0;
        INPUT_A = 0;
        INPUT_B = 0;

        #20 reset = 0;
        #10 start = 1;

        for (integer i=0; i<8; i=i+1) begin
            INPUT_A = test_data[i];
            INPUT_B = test_data[15-i];
            #10 start = 0;
        end

        wait(output_en);
        $display("Starting Output Cycle...");

        repeat (8) begin
            @(posedge clk);
            if (output_en) begin
                $display("Index %d: %f | Index %d: %f",
                         INDEX_A, $itor(OUTPUT_A)/256.0,
                         INDEX_B, $itor(OUTPUT_B)/256.0);
            end
        end

        #100 $finish;
    end
endmodule
