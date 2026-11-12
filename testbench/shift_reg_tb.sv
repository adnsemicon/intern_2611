module shift_reg_tb; 

    logic clk = 0;
    logic d   = 0;
    logic bad_q1  = 0, bad_q2  = 0; // Broken '='
    logic good_q1 = 0, good_q2 = 0; // Correct '<='

    // Clock (ticks up at 5ns, 15ns, 25ns)
    always #5 clk = ~clk;

    // 1. BROKEN: Blocking '='
    always_ff @(posedge clk) begin
        bad_q1 = d;
        bad_q2 = bad_q1;
    end

    // 2. CORRECT: Non-blocking '<='
    always_ff @(posedge clk) begin
        good_q1 <= d;
        good_q2 <= good_q1;
    end

    // SUPER SIMPLE TESTBENCH
    initial begin
        // Automatically prints every time any signal changes
        $monitor("Time=%0t | d=%b | Broken: %b,%b | Correct: %b,%b",
                 $time, d, bad_q1, bad_q2, good_q1, good_q2);

        #2  d = 1;   // Turn 'd' ON at 2ns
        #20 $finish; // Let 2 clock ticks pass, then stop!
    end

endmodule

