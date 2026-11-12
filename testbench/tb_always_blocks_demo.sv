module tb_always_blocks_demo;

    // Input declarations
    logic [3:0] a, b;
    logic clk;
    logic rst_n;
    logic d;
    logic en;

    // Output declarations
    logic [3:0] sum;
    logic [3:0] carry;
    logic q_ff;
    logic q_latch;


    // DUT Instantiation
    always_blocks_demo dut (
        .a(a),
        .b(b),
        .clk(clk),
        .rst_n(rst_n),
        .d(d),
        .en(en),
        .sum(sum),
        .carry(carry),
        .q_ff(q_ff),
        .q_latch(q_latch)
    );


    // Clock Generation
    always #5 clk = ~clk;


    // Test Stimulus
    initial begin

        $monitor("Time=%0t | a=%b b=%b | sum=%b carry=%b | d=%b en=%b | q_ff=%b q_latch=%b",
                 $time, a, b, sum, carry, d, en, q_ff, q_latch);

        // Initial values
        clk = 0;
        rst_n = 1;
        a = 4'b0101;
        b = 4'b0011;
        d = 0;
        en = 0;

        // Test asynchronous reset
        #1 rst_n = 0;

        #2 rst_n = 1;

        // Test flip-flop and latch
        d = 1;
        en = 1;

        #5;

        // Test latch hold
        en = 0;
        d = 0;

        // Change combinational inputs
        #1;
        a = 4'b1010;
        b = 4'b0101;

        // Wait for next clock edge
        #7;

        // Enable latch again
        en = 1;

        #2;

        $display("Simulation Completed!");

        $finish;

    end

endmodule
