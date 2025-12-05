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
    always #4 clk = ~clk;

    initial begin
        // Init
        clk = 0;
        rst = 1;
        x   = 16'd0; #80;

        // Release reset
        rst = 0; 

        // --- SAMPLE SEQUENCE ---

        // Push 8 samples (for first mean)
        x = 16'd8;  #8;
        x = 16'd10; #8;
        x = 16'd8; #8;
        x = 16'd10; #8;
        x = 16'd8; #8;
        x = 16'd10; #8;
        x = 16'd8; #8;
        x = 16'd10; #8;
        //mean = 9
        // Another block of samples
        x = 16'd10; #8;
        x = 16'd10; #8;
        x = 16'd10; #8;
        x = 16'd10; #8;
        x = 16'd10; #8;
        x = 16'd10; #8;
        x = 16'd10; #8;
        x = 16'd10; #8;
        
       x = 16'd0;  #8;
        x = 16'd10; #8;
        x = 16'd0; #8;
        x = 16'd10; #8;
        x = 16'd0; #8;
        x = 16'd10; #8;
        x = 16'd0; #8;
        x = 16'd10; #8;
        
        x = 16'd10; #8;
        x = 16'd10; #8;
        x = 16'd10; #8;
        x = 16'd10; #8;
        x = 16'd10; #8;
        x = 16'd10; #8;
        x = 16'd10; #8;
        x = 16'd10; #8;
        // Finish simulation
    
    end

endmodule
