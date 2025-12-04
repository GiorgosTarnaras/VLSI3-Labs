`timescale 1ns/1ps

module tb_merge_sort;

    // Inputs
    reg clk;
    reg rst;
    reg en;
    reg [15:0] In_a, In_b, In_c, In_d;

    // Outputs
    wire [15:0] Sorted_Out_a, Sorted_Out_b, Sorted_Out_c, Sorted_Out_d;

    // Instantiate the DUT
    merge_sort DUT (
        .clk(clk),
        .rst(rst),
        .en(en),
        .In_a(In_a),
        .In_b(In_b),
        .In_c(In_c),
        .In_d(In_d),
        .Sorted_Out_a(Sorted_Out_a),
        .Sorted_Out_b(Sorted_Out_b),
        .Sorted_Out_c(Sorted_Out_c),
        .Sorted_Out_d(Sorted_Out_d)
    );

    // Clock generation: 8 ns period
    initial clk = 0;
    always #4 clk = ~clk;

    // Stimulus
    initial begin
        // Initialize
        rst = 1; en = 0;
        In_a = 0; In_b = 0; In_c = 0; In_d = 0;

        // Release reset after 2 cycles
        @(posedge clk); @(posedge clk);
        rst = 0; en = 1; #76;

        // --- Example 1 ---
        
        In_a = 16'd8;
        In_b = 16'd10;
        In_c = 16'd5;
        In_d = 16'd15;#24;

      



        // --- Example 2 ---
       
        In_a = 16'd17;
        In_b = 16'd3;
        In_c = 16'd7;
        In_d = 16'd12;#24;

#100;
        $stop;
    end

endmodule
