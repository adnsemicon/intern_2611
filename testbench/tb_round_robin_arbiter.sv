`include "round_robin_arbiter_if.sv"

module tb_round_robin_arbiter #(
    parameter bit ERROR_INJECT = 0   // 0: normal, 1: inject faults
);

  localparam int N = 4;

  // Pass / Fail Counters & Test Selection
  int    pass_count;
  int    fail_count;
  string test_name;

  // Interface & DUT Instantiation
  round_robin_arbiter_if #(.N(N)) intf ();

  round_robin_arbiter #(.N(N)) dut (
      .clk_i   (intf.clk_i),
      .arst_ni (intf.arst_ni),
      .req_i   (intf.req_i),
      .gnt_o   (intf.gnt_o)
  );

  // =========================================================================
  // 1. TIMING & CONTROL TASKS
  // =========================================================================
  task automatic start_clock(input int half_period_ns = 5);
    fork
      forever #half_period_ns intf.clk_i = ~intf.clk_i;
    join_none
  endtask

  task automatic apply_reset();
    intf.arst_ni = 1'b0;
    intf.req_i   = '0;
    #20;
    intf.arst_ni = 1'b1;
  endtask

  // =========================================================================
  // 2. DRIVING & CHECKING TASKS
  // =========================================================================
  task automatic check(input logic ok, input string msg);
    if (ok) begin
      pass_count++;
      $display("[PASS] @ %0t | %s", $time, msg);
    end else begin
      fail_count++;
      $display("[FAIL] @ %0t | %s", $time, msg);
    end
  endtask

  // Silent pass check (keeps logs clean for 21,000 random cycles)
  task automatic tc_chk(input logic ok, input string msg);
    if (ok) pass_count++;
    else    check(1'b0, msg);
  endtask

  // Main workhorse: drives request at negedge, checks combinational grant, clocks edge
  task automatic apply_and_check(
      input logic [N-1:0] request,
      input logic [N-1:0] expected,
      input string        msg
  );
    logic [N-1:0] exp = ERROR_INJECT ? ~expected : expected;

    @(negedge intf.clk_i);
    intf.req_i = request;
    #1;
    check(intf.gnt_o === exp, $sformatf("%s (exp=%b, got=%b)", msg, exp, intf.gnt_o));

    @(posedge intf.clk_i);
    #1;
  endtask

  task automatic tc_drive(input logic [N-1:0] r);
    @(negedge intf.clk_i);
    intf.req_i = r;
    #1;
  endtask

  task automatic tc_idle();
    @(negedge intf.clk_i);
    intf.req_i = '0;
    #1;
  endtask

  function automatic logic [N-1:0] tc_onehot(input int k);
    tc_onehot    = '0;
    tc_onehot[k] = 1'b1;
  endfunction

  // =========================================================================
  // 3. SUMMARY REPORT
  // =========================================================================
  task automatic report_summary();
    $display("\n========================================================");
    $display("                TESTBENCH EXECUTION SUMMARY             ");
    $display("========================================================");
    $display(" Tests PASSED  : %0d", pass_count);
    $display(" Tests FAILED  : %0d", fail_count);
    $display("========================================================");
    if (fail_count != 0) begin
      $fatal(1, "[FATAL] Finished with %0d failures!", fail_count);
    end else begin
      $display("[SUCCESS] All checks completed successfully!\n");
    end
  endtask

  // =========================================================================
  // 4. TESTCASE INCLUDES
  // =========================================================================
  `include "Round_robin_tb/tc1.sv"
  `include "Round_robin_tb/tc2.sv"
  `include "Round_robin_tb/tc3.sv"
  `include "Round_robin_tb/tc4.sv"
  `include "Round_robin_tb/tc5.sv"
  `include "Round_robin_tb/tc6.sv"
  `include "Round_robin_tb/tc7.sv"
  `include "Round_robin_tb/tc8.sv"
  `include "Round_robin_tb/tc9.sv"
  `include "Round_robin_tb/tc10.sv"

  // =========================================================================
  // 5. MAIN EXECUTION
  // =========================================================================
  initial begin
    pass_count = 0;
    fail_count = 0;
    if (!$value$plusargs("TEST=%s", test_name)) test_name = "all";

    $timeformat(-9, 1, " ns", 20);
    $dumpfile("tb_round_robin_arbiter.vcd");
    $dumpvars(0, tb_round_robin_arbiter);

    // Initial power-on: clock stopped, apply reset, then start clock
    intf.clk_i = 1'b0;
    apply_reset();
    #10;
    start_clock();
    @(posedge intf.clk_i);

    $display("\n[TB] Running with TEST = '%s', ERROR_INJECT = %0b...", test_name, ERROR_INJECT);

    case (test_name)
      "tc1":    tc1();
      "tc2":    tc2();
      "tc3":    tc3();
      "tc4":    tc4();
      "tc5":    tc5();
      "tc6":    tc6();
      "tc7":    tc7();
      "tc8":    tc8();
      "tc9":    tc9();
      "tc10":   tc10();
      default: begin
        tc1(); tc2(); tc3(); tc4(); tc5();
        tc6(); tc7(); tc8(); tc9(); tc10();
      end
    endcase

    report_summary();
    $finish;
  end

endmodule