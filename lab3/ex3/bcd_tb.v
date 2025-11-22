`timescale 1ns/1ps

module tb_BCD_counter;

    reg clk;
    reg rst;
    wire [11:0] BCD;

    BCD_counter DUT (
        .clk(clk),
        .rst(rst),
        .BCD(BCD)
    );

    always #1.5 clk = ~clk;

    initial begin
    
        clk = 1;
        rst = 0;
        $stop;   
    end

    initial begin
        $display("Time\t rst clk  BCD");
        $monitor("%0dns\t %b   %b   %d-%d-%d (BCD = %b)", 
            $time, rst, clk,
            BCD[11:8], BCD[7:4], BCD[3:0],
            BCD
        );
    end

endmodule
