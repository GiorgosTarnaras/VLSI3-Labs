`timescale 1ns/1ps

module tb_FSM_timer;

    
    // DUT signals
    reg  clk;
    reg  x;
    wire y;

    // Instantiate DUT
    FSM_timer dut (
        .clk(clk),
        .x(x),
        .y(y)
    );


    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    // Stimulus
    initial begin
        // Default
        x = 0;

        // Wait a few cycles
        repeat (2) @(posedge clk);
        
        // Drive x high -> A to B
        #0.5;
        x = 1;
        repeat (2) @(posedge clk);

        // Drop x early -> should go B to C at T1
        x = 0;
        repeat (4) @(posedge clk);

        // Go back to A, then re-enter B and timeout
        x = 1;
        repeat (4) @(posedge clk);

        // End simulation
        $finish;
    end

endmodule
