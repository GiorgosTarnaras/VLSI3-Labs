`timescale 1ns/1ps

module tb_FSM_timer;

    // Parameters (match VHDL generics)
    localparam integer T1 = 2;
    localparam integer T2 = 4;

    // DUT signals
    reg  clk;
    reg  x;
    wire y;

    // Instantiate DUT
    FSM_timer #(
        .T1(T1),
        .T2(T2)
    ) dut (
        .clk(clk),
        .x(x),
        .y(y)
    );

    // Clock generation: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        // Default
        x = 0;

        // Wait a few cycles
        repeat (2) @(posedge clk);

        // Drive x high -> A to B
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

    // Simple monitor
    initial begin
        $display("time  clk  x  y");
        $monitor("%4t   %b    %b  %b", $time, clk, x, y);
    end

endmodule
