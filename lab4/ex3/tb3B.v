`timescale 1ns/1ps

module tb_mean_value;

    // Inputs to DUT
    reg         clk;
    reg         rst;
    reg [15:0]  x0, x1, x2, x3, x4, x5, x6, x7;

    // Output from DUT
    wire [15:0] y;

    // Instantiate the VHDL DUT
    mean_value DUT (
        .clk(clk),
        .rst(rst),
        .x0(x0),
        .x1(x1),
        .x2(x2),
        .x3(x3),
        .x4(x4),
        .x5(x5),
        .x6(x6),
        .x7(x7),
        .y(y)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    initial begin
        // Init
        clk = 0;
        rst = 1;
        x0   = 16'd0;
        x1   = 16'd0;
        x2   = 16'd0;
        x3   = 16'd0;
        x4   = 16'd0;
        x5   = 16'd0;
        x6   = 16'd0;
        x7   = 16'd0;
        // Release reset
        #20 rst = 0;

        // --- SAMPLE SEQUENCE ---

        // Push 8 samples (for first mean)
        x0 = 16'd8;  
        x1 = 16'd10; 
        x2 = 16'd8; 
        x3 = 16'd10; 
        x4 = 16'd8; 
        x5 = 16'd10;
        x6 = 16'd8; 
        x7 = 16'd10; #10;
        // mean of 8 and 10 is 9

        x0 = 16'd8;  
        x1 = 16'd12; 
        x2 = 16'd8; 
        x3 = 16'd12; 
        x4 = 16'd8; 
        x5 = 16'd12;
        x6 = 16'd8; 
        x7 = 16'd12; #10;
        // mean of 8 and 12 is 10

        
        #100 $stop;
    end

endmodule
