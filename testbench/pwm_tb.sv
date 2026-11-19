module pwm_tb;

    //==================================================
    // PARAMETERS
    //==================================================
    localparam int NUM_CHANNELS = 8;
    localparam int ADDR_WIDTH   = 4;
    localparam int DATA_WIDTH   = 8;
    localparam int RESOLUTION   = 8;
    localparam int PWM_PERIOD   = (1 << RESOLUTION);

    //==================================================
    // SIGNALS
    //==================================================
    logic clk_i;
    logic arst_ni;
    logic [ADDR_WIDTH-1:0] addr_i;
    logic [DATA_WIDTH-1:0] wdata_i;
    logic wen_i;
    logic [DATA_WIDTH-1:0] rdata_o;
    logic [NUM_CHANNELS-1:0] pwm_o;

    //==================================================
    // TEST / SUMMARY VARIABLES
    //==================================================
    int pass_count = 0;
    int fail_count = 0;
    int test_number;

    //==================================================
    // DUT
    //==================================================
    pwm_top #(
        .NUM_CHANNELS (NUM_CHANNELS),
        .ADDR_WIDTH   (ADDR_WIDTH),
        .DATA_WIDTH   (DATA_WIDTH),
        .RESOLUTION   (RESOLUTION)
    ) dut (
        .clk_i     (clk_i),
        .arst_ni   (arst_ni),
        .addr_i    (addr_i),
        .wdata_i   (wdata_i),
        .wen_i     (wen_i),
        .rdata_o   (rdata_o),
        .pwm_o     (pwm_o)
    );

    //==================================================
    // CLOCK
    //==================================================
    initial clk_i = 1'b0;
    always #5 clk_i = ~clk_i;  // 10 ns clock period

    //==================================================
    // HELPER TASKS
    //==================================================

    // Reset and initialize DUT input signals
    task automatic reset_dut();
        addr_i  = '0;
        wdata_i = '0;
        wen_i   = 1'b0;
        arst_ni = 1'b0;
        repeat (2) @(posedge clk_i);
        @(negedge clk_i);
        arst_ni = 1'b1;
        @(posedge clk_i);
    endtask

    // Write one duty-cycle or enable register
    task automatic write_reg(
        input logic [ADDR_WIDTH-1:0] address,
        input logic [DATA_WIDTH-1:0] data
    );
        @(negedge clk_i);
        addr_i  = address;
        wdata_i = data;
        wen_i   = 1'b1;
        @(posedge clk_i);
        #1;
        @(negedge clk_i);
        wen_i = 1'b0;
    endtask

    // Read one register through the combinational read mux
    task automatic read_reg(
        input logic [ADDR_WIDTH-1:0] address,
        output logic [DATA_WIDTH-1:0] data
    );
        @(negedge clk_i);
        addr_i = address;
        wen_i  = 1'b0;
        #1;
        data = rdata_o;
    endtask

    // Compare read data with expected value and account for result
    task automatic check_reg(
        input logic [ADDR_WIDTH-1:0] address,
        input logic [DATA_WIDTH-1:0] expected
    );
        logic [DATA_WIDTH-1:0] actual;
        read_reg(address, actual);
        check(actual === expected,
              $sformatf("Register addr=%0h expected=%0h actual=%0h",
                        address, expected, actual));
    endtask

    // Count HIGH samples over one PWM counter period.
    // DUT counter is shared and free-running; this task samples 256 clock cycles.
    task automatic check_pwm_period(
        input int channel,
        input int expected_high
    );
        int high_count;
        high_count = 0;
        repeat (PWM_PERIOD) begin
            @(posedge clk_i);
            #1;
            if (pwm_o[channel]) high_count++;
        end
        check(high_count == expected_high,
              $sformatf("PWM CH%0d expected HIGH=%0d sampled HIGH=%0d",
                        channel, expected_high, high_count));
    endtask

    // Verify all channels disabled by the supplied mask remain LOW.
    // enable_mask bits set to 0 indicate channels expected to be disabled.
    task automatic check_disabled_mask(input logic [NUM_CHANNELS-1:0] enable_mask);
        int i;
        for (i = 0; i < NUM_CHANNELS; i++) begin
            if (!enable_mask[i]) begin
                check(pwm_o[i] === 1'b0,
                      $sformatf("Disabled CH%0d output expected LOW, got %b",
                                i, pwm_o[i]));
            end
        end
    endtask

    // Common PASS/FAIL accounting task
    task automatic check(input bit ok, input string message);
        if (ok) begin
            pass_count++;
            $display("[PASS] %s", message);
        end else begin
            fail_count++;
            $display("[FAIL] %s", message);
        end
    endtask

    //==================================================
    // TEST CASE FILES
    //==================================================
   //========================================
// TEST CASE FILES
//========================================

`include "tc01_reset.sv"
`include "tc02_register_access.sv"
`include "tc03_write_protection.sv"
`include "tc04_pwm_accuracy.sv"
`include "tc05_counter_frequency.sv"
`include "tc06_corner_cases.sv"
    //==================================================
    // MAIN TEST
    //==================================================
    initial begin
        pass_count = 0;
        fail_count = 0;
        test_number = -1;

        addr_i  = '0;
        wdata_i = '0;
        wen_i   = 1'b0;
        arst_ni = 1'b0;

        $timeformat(-9, 1, " ns", 10);
        $dumpfile("pwm_tb.vcd");
        $dumpvars(0, pwm_tb);

        if (!$value$plusargs("TEST=%d", test_number))
            test_number = 0; // TEST=0 runs all test cases

        $display("Running PWM test selection: TEST=%0d", test_number);

        reset_dut();

        case (test_number)
            0: begin
                tc01_reset();
                tc02_register_access();
                tc03_write_protection();
                tc04_pwm_accuracy();
                tc05_counter_frequency();
                tc06_corner_cases();
            end
            1: tc01_reset();
            2: tc02_register_access();
            3: tc03_write_protection();
            4: tc04_pwm_accuracy();
            5: tc05_counter_frequency();
            6: tc06_corner_cases();
            default: $fatal(1, "Invalid TEST=%0d. Valid range: 0-6 (0=all)", test_number);
        endcase

        $display("\n======================================");
        $display("pwm_tb summary: pass=%0d fail=%0d", pass_count, fail_count);
        $display("======================================");

        if (fail_count != 0)
            $fatal(1, "PWM TESTBENCH FAILED: fail count=%0d", fail_count);

        $display("PWM TESTBENCH PASSED!");
        repeat (2) @(posedge clk_i);
        $finish;
    end

endmodule
