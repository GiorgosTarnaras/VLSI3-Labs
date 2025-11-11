`timescale 1ns / 1ps

module tb_parity_checker_rearrange_2;
    // Parameters
    parameter N = 8;
    
    // Signals
    reg [N-1:0] x;
    wire [N-1:0] y;
    wire parity_bit;
    
    // Instantiate the Unit Under Test (UUT)
    parity_checker_rearrange_2 #(
        .N(N)
    ) uut (
        .x(x),
        .y(y),
        .parity_bit(parity_bit)
    );
    
    integer i;
    
    initial begin
        $display("Testing Parity Checker with Rearrange");
        $display("Time\t x\t\t y\t\t parity_bit");
        $display("----\t ----\t\t ----\t\t ----------");
        
        // Test various input patterns
    //    for (i = 0; i < 256; i = i + 1) begin
     //       x = i;
      //      #10;
    //        $display("%0t\t %b\t %b\t %b", $time, x, y, parity_bit);
    //    end
        
        // Additional specific test cases
        x = 8'b00000000; #20;
        $display("Test all zeros: x=%b y=%b parity=%b", x, y, parity_bit);
        
        x = 8'b11111111; #20;
        $display("Test all ones:  x=%b y=%b parity=%b", x, y, parity_bit);
        
        x = 8'b10101010; #20;
        $display("Test pattern:   x=%b y=%b parity=%b", x, y, parity_bit);
        
        x = 8'b01010101; #20;
        $display("Test pattern:   x=%b y=%b parity=%b", x, y, parity_bit);
        
        $finish;
    end
endmodule