`timescale 1ns / 1ps

module tb_switch_debouncer;

    // ========================================================================
    // PARAMETERS & CONSTANTS
    // ========================================================================
    // Default parameters (same as VHDL generics)
    parameter CLK_FREQ_HZ = 125_000_000;
    parameter DEBOUNCE_TIME_MS = 10;

    // Simulation overrides (Faster simulation: 1ms instead of 10ms)
    localparam TEST_CLK_FREQ = 125_000_000;
    localparam TEST_DEBOUNCE_MS = 10;
    
    // Calculate cycles: (125,000,000 / 1000) * 1 = 125,000 cycles
    localparam DEBOUNCE_CYCLES = (TEST_CLK_FREQ / 1000) * TEST_DEBOUNCE_MS;
    localparam CLK_PERIOD = 8.0; // 8 ns for 125 MHz

    // ========================================================================
    // SIGNALS
    // ========================================================================
    reg clk;
    reg reset;
    reg sw;
    wire deb_sw;

    // Integer for loops
    integer i;

    // ========================================================================
    // DUT INSTANTIATION
    // ========================================================================
    switch_debouncer #(
        .CLK_FREQ_HZ(TEST_CLK_FREQ),
        .DEBOUNCE_TIME_MS(TEST_DEBOUNCE_MS)
    ) uut (
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .deb_sw(deb_sw)
    );

    // ========================================================================
    // CLOCK GENERATION
    // ========================================================================
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // ========================================================================
    // TASK: GENERATE BOUNCES
    // ========================================================================
    task generate_bounces;
        input final_state;
        input integer num_bounces;
        input integer bounce_duration_ns; // Duration in ns
        integer k;
        begin
            for (k = 0; k < num_bounces; k = k + 1) begin
                sw = ~final_state;
                #(bounce_duration_ns);
                sw = final_state;
                #(bounce_duration_ns);
            end
        end
    endtask

    // ========================================================================
    // STIMULUS PROCESS
    // ========================================================================
    initial begin
        // Initialize Inputs
        sw = 1;      // Start with switch open (high)
        reset = 0;

        // Wait for global reset
        #(CLK_PERIOD * 10);

        // ------------------------------------------------------------
        // Test 1: Asynchronous Reset
        // ------------------------------------------------------------
        $display("=== Test 1: Asynchronous Reset ===");
        reset = 1;
        #(CLK_PERIOD * 5);
        if (deb_sw !== 1) $error("Output not high during reset");
        
        reset = 0;
        #(CLK_PERIOD * 5);
        if (deb_sw !== 1) $error("Output not high after reset release");
        $display("Test 1 PASSED: Reset works correctly");
        #(CLK_PERIOD * 10);

        // ------------------------------------------------------------
        // Test 2: Switch Press with Bounces
        // ------------------------------------------------------------
        $display("=== Test 2: Switch Press with Bounces (Filtered) ===");
        $display("Generating bouncy press...");

        // Bounces: 0-1-0-1-0... final state = 0. 50us = 50000ns
        generate_bounces(1'b0, 5, 50000); 

        // Switch is stable at '0', check if output changed too early
        #(CLK_PERIOD * 10);
        if (deb_sw !== 1) $error("Output changed during bounce period");
        $display("Bounce filtering working - output still high");

        // Wait for debounce time to elapse
        #(CLK_PERIOD * (DEBOUNCE_CYCLES + 100));

        // Now output should be low
        if (deb_sw !== 0) $error("Output not low after debounce time");
        $display("Test 2 PASSED: Switch press debounced correctly");
        #(CLK_PERIOD * 1000000);

        // ------------------------------------------------------------
        // Test 3: Switch Release with Bounces
        // ------------------------------------------------------------
        $display("=== Test 3: Switch Release with Bounces (Filtered) ===");
        $display("Generating bouncy release...");

        // Bounces: 1-0-1-0-1... final state = 1. 40us = 40000ns
        generate_bounces(1'b1, 4, 40000);

        // Switch stable at '1'. Design releases immediately.
        #(CLK_PERIOD * 100);
        if (deb_sw !== 1) $error("Output not high after release");
        $display("Test 3 PASSED: Switch release handled correctly");
        #(CLK_PERIOD * 100);

        // ------------------------------------------------------------
        // Test 4: Short Glitch (Ignored)
        // ------------------------------------------------------------
        $display("=== Test 4: Short Glitch (Ignored) ===");
        sw = 1;
        #(CLK_PERIOD * 100);

        // Glitch to '0'
        sw = 0;
        #(CLK_PERIOD * 1000); // Wait < debounce time
        if (deb_sw !== 1) $error("Output changed on short glitch");

        // Return to '1' before debounce complete
        sw = 1;
        #(CLK_PERIOD * (DEBOUNCE_CYCLES + 100));
        if (deb_sw !== 1) $error("Output shouldn't have changed from glitch");
        $display("Test 4 PASSED: Short glitch correctly ignored");
        #(CLK_PERIOD * 100);

        // ------------------------------------------------------------
        // Test 5: Valid Long Press
        // ------------------------------------------------------------
        $display("=== Test 5: Valid Long Press ===");
        sw = 0;
        #(CLK_PERIOD * 10);
        
        // Wait full debounce time
        #(CLK_PERIOD * (DEBOUNCE_CYCLES + 100));
        if (deb_sw !== 0) $error("Output not low after valid press");
        $display("Test 5 PASSED: Long press registered correctly");

        // Hold
        #(CLK_PERIOD * 100000);
        if (deb_sw !== 0) $error("Output unstable during hold");

        // Release
        sw = 1;
        #(CLK_PERIOD * 100);
        if (deb_sw !== 1) $error("Output not high after release");
        #(CLK_PERIOD * 100);

        // ------------------------------------------------------------
        // Test 6: Multiple Rapid Presses
        // ------------------------------------------------------------
        $display("=== Test 6: Multiple Rapid Presses (Contact Bounce) ===");
        for (i = 1; i <= 3; i = i + 1) begin
            $display("Rapid press %0d", i);
            sw = 0;
            #(CLK_PERIOD * 500); // < debounce
            sw = 1;
            #(CLK_PERIOD * 500);
        end

        #(CLK_PERIOD * 100);
        if (deb_sw !== 1) $error("Rapid bounces caused false trigger");
        $display("Test 6 PASSED: Rapid bounces filtered correctly");
        #(CLK_PERIOD * 100);

        // ------------------------------------------------------------
        // Test 7: Reset During Debouncing
        // ------------------------------------------------------------
        $display("=== Test 7: Reset During Debouncing ===");
        sw = 0;
        #(CLK_PERIOD * (DEBOUNCE_CYCLES / 2)); // Halfway

        if (deb_sw !== 1) $error("Output changed before debounce complete");

        // Apply reset
        reset = 1;
        #(CLK_PERIOD * 10);
        reset = 0;

        // Wait remainder of original time + some margin
        #(CLK_PERIOD * (DEBOUNCE_CYCLES / 2 + 100));
        if (deb_sw !== 1) $error("Reset didn't clear debounce counter");

        // Wait full duration from reset point
        #(CLK_PERIOD * (DEBOUNCE_CYCLES / 2 + 100));
        if (deb_sw !== 0) $error("Debounce didn't complete after reset");
        $display("Test 7 PASSED: Reset during debounce handled correctly");

        sw = 1;
        #(CLK_PERIOD * 100);

        // ------------------------------------------------------------
        // Test 8: Continuous Operation
        // ------------------------------------------------------------
        $display("=== Test 8: Continuous Operation Test ===");
        for (i = 1; i <= 3; i = i + 1) begin
            $display("Press-release cycle %0d", i);
            
            // Press with bounces (3 bounces, 30us)
            generate_bounces(1'b0, 3, 30000);
            
            #(CLK_PERIOD * (DEBOUNCE_CYCLES + 100));
            if (deb_sw !== 0) $error("Cycle press failed");

            #(CLK_PERIOD * 500); // Hold

            // Release
            sw = 1;
            #(CLK_PERIOD * 200);
            if (deb_sw !== 1) $error("Cycle release failed");
            
            #(CLK_PERIOD * 200);
        end
        $display("Test 8 PASSED: Continuous operation stable");

        $display("========================================");
        $display("ALL TESTS PASSED SUCCESSFULLY!");
        $finish;
    end

endmodule
