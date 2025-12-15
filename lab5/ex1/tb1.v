`timescale 1ns/1ps

module arbiter_tb;
  reg clk, rst;
  reg [1:0] r;
  wire [1:0] g;
  
  // Instantiate arbiter
  arbiter dut (
    .clk(clk),
    .rst(rst),
    .r(r),
    .g(g)
  );
  
  // Clock generation (8ns period = 4ns high, 4ns low)
  initial begin
    clk = 0;
    forever #4 clk = ~clk;
  end
  
  // Test stimulus
  initial begin
    // Initialize
    rst = 1;
    r = 2'b00;
    #16;
    
    // Release reset
    rst = 0;
    #8;
    
    // Request from agent 0
    r = 2'b01;
    #32;
    
    // Request from agent 1
    r = 2'b10;
    #32;
    
    // Both request
    r = 2'b11;
    #32;
    
    // No request
    r = 2'b00;
    #16;
    
    $finish;
  end
  
  // Monitor
  initial begin
    $monitor("Time=%0t rst=%b r=%b g=%b", $time, rst, r, g);
  end
  
endmodule