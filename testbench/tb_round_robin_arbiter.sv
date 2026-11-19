

`include "round_robin_arbiter_if.sv"

module tb_round_robin_arbiter #(
    parameter int TEST         = 0,  // 0: all, 1: tc1, 2: tc2, 3: tc3, 4: tc4, 5: tc5 (fault injection)
    parameter bit ERROR_INJECT = 0   // 0: normal, 1: globally inject corrupted expected values
);

  // LOCAL PARAMETERS (Core count: 4, 8, etc.)
  localparam int N = 4;

  // PASS / FAIL COUNTERS
  int pass_count;
  int fail_count;

  // INTERFACE INSTANTIATION
  round_robin_arbiter_if #(.N(N)) intf ();

  // DUT INSTANTIATION
  round_robin_arbiter #(
      .N(N)
  ) dut (
      .clk_i   (intf.clk_i),
      .arst_ni (intf.arst_ni),
      .req_i   (intf.req_i),
      .gnt_o   (intf.gnt_o)
  );

  // =========================================================================
  // COMMON TASKS (All teammates can call these directly from their testcases)
  // =========================================================================

  // 1. Clock Generation Task
  task automatic start_clock(input int half_period_ns = 5);
    fork
      forever #half_period_ns intf.clk_i = ~intf.clk_i;
    join_none
  endtask

  // 2. Reset Task: asserts active-low reset, clears requests, releases synchronously
  task automatic apply_reset(input int reset_cycles = 2);
    intf.arst_ni = 1'b0;
    intf.req_i   = '0;
    repeat (reset_cycles) @(negedge intf.clk_i);
    intf.arst_ni = 1'b1;
    #1;
  endtask

  // 3. Self-Checking Assertion Task: increments pass/fail count and prints log
  task automatic check(input logic ok, input string msg);
    if (ok) begin
      pass_count++;
      $display("[PASS] @ %0t | %s", $time, msg);
    end else begin
      fail_count++;
      $display("[FAIL] @ %0t | %s", $time, msg);
    end
  endtask

  // 4. Drive Request and Check Grant (Workhorse task: drives at negedge, checks combinational grant, advances clock)
  task automatic apply_and_check(
      input logic [N-1:0] request,
      input logic [N-1:0] expected,
      input string        msg
  );
    logic [N-1:0] check_expected;
    check_expected = (ERROR_INJECT) ? ~expected : expected;

    @(negedge intf.clk_i);
    intf.req_i = request;

    // Check combinational grant output before next posedge
    #1;
    check(intf.gnt_o === check_expected,
          $sformatf("%s (expected=%b, got=%b)%s",
                    msg, check_expected, intf.gnt_o,
                    ERROR_INJECT ? " [FAULT INJECTED]" : ""));

    // Allow clock edge for arbiter priority state to update
    @(posedge intf.clk_i);
    #1;
  endtask

  // 5. Summary Reporting Task
  task automatic report_summary();
    $display("\n========================================================");
    $display("                TESTBENCH EXECUTION SUMMARY             ");
    $display("========================================================");
    $display(" Tests PASSED  : %0d", pass_count);
    $display(" Tests FAILED  : %0d", fail_count);
    $display("========================================================");
    if (fail_count != 0) begin
      $fatal(1, "[FATAL] tb_round_robin_arbiter finished with %0d failures!", fail_count);
    end else if (pass_count > 0) begin
      $display("[SUCCESS] All checks completed successfully!\n");
    end else begin
      $display("[INFO] Simulation finished with 0 checks executed.\n");
    end
  endtask

   `include "Round_robin_tb/tc1.sv"
   `include "Round_robin_tb/tc2.sv"
   `include "Round_robin_tb/tc3.sv"
   `include "Round_robin_tb/tc4.sv"
   `include "Round_robin_tb/tc5.sv"

  // =========================================================================
  // MAIN INITIAL BLOCK
  // =========================================================================
  initial begin
    pass_count = 0;
    fail_count = 0;

    $timeformat(-9, 1, " ns", 20);
    $dumpfile("tb_round_robin_arbiter.vcd");
    $dumpvars(0, tb_round_robin_arbiter);

    // 1. Initial state: hold clock low and active-low reset asserted
    intf.clk_i   = 1'b0;
    intf.arst_ni = 1'b0;
    intf.req_i   = '0;
    #20;

    // 2. Release reset
    intf.arst_ni = 1'b1;
    #20;

    // 3. Start clock
    start_clock();
    @(posedge intf.clk_i);

    // =======================================================================
    // 4. RUN TESTS based on module parameter (NO plusargs!)
    // =======================================================================
    $display("\n[TB] Running with TEST parameter = %0d, ERROR_INJECT = %0b...", TEST, ERROR_INJECT);

    case (TEST)
      1: tc1();
      2: tc2();
      3: tc3();
      4: tc4();
      5: tc5();
      default: begin
        tc1();
        tc2();
        tc3();
        tc4();
      end
    endcase

    // 5. Final summary report and simulation finish
    report_summary();
    $finish;
  end

endmodule

