`timescale 1ns/1ps

module tb_mean_value;

    // Inputs to DUT
    reg         clk;
    reg         rst;
    reg [15:0]  x;

    // Output from DUT
    wire [15:0] y;

    // Instantiate the VHDL DUT
    mean_value DUT (
        .clk(clk),
        .rst(rst),
        .x(x),
        .y(y)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    initial begin
        // Init
        clk = 0;
        rst = 1;
        x   = 16'd0;

        // Release reset
        #20 rst = 0;

        // --- SAMPLE SEQUENCE ---

        // Push 8 samples (for first mean)
        x = 16'd8;  #10;
        x = 16'd10; #10;
        x = 16'd8; #10;
        x = 16'd10; #10;
        x = 16'd8; #10;
        x = 16'd10; #10;
        x = 16'd8; #10;
        x = 16'd10; #10;
        //mean = 9
        // Another block of samples
        x = 16'd10; #10;
        x = 16'd10; #10;
        x = 16'd10; #10;
        x = 16'd10; #10;
        x = 16'd10; #10;
        x = 16'd10; #10;
        x = 16'd10; #10;
        x = 16'd10; #10;
        //mean = 10
        // Finish simulation
        #100 $stop;
    end

endmodule
