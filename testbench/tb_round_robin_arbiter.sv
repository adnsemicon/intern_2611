`timescale 1ns/1ps

module tb_round_robin_arbiter;

  `include "vip/round_robin_arbiter_if.sv"

  // LOCAL PARAMETERS
  localparam int N = 4;

  // SIGNALS
  logic clk_i;
  logic arst_ni;

  int pass_count;
  int fail_count;

  // INTERFACE INSTANTIATION
  round_robin_arbiter_if #(.N(N)) intf (
      .clk_i   (clk_i),
      .arst_ni (arst_ni)
  );

  // DUT INSTANTIATION
  round_robin_arbiter #(
      .N(N)
  ) dut (
      .clk_i   (intf.clk_i),
      .arst_ni (intf.arst_ni),
      .req_i   (intf.req),
      .gnt_o   (intf.gnt)
  );

  // METHODS

  // Clock generation task
  task automatic start_clock();
    fork
      forever #5 clk_i = ~clk_i;
    join_none
  endtask

  // Reset task
  task automatic apply_reset();
    arst_ni  = 0;
    intf.req = '0;
    #2;
    @(negedge clk_i);
    arst_ni  = 1;
    #1;
  endtask

  // Check task
  task automatic check(input logic ok, input string msg);
    if (ok) begin
      pass_count++;
      $display("[PASS] %s", msg);
    end else begin
      fail_count++;
      $display("[FAIL] %s", msg);
    end
  endtask

  // Apply request and check grant
  task automatic apply_and_check(
      input logic [N-1:0] request,
      input logic [N-1:0] expected,
      input string        msg
  );
    @(negedge clk_i);
    intf.req = request;

    // Check combinational grant before clock update
    #1;
    check(intf.gnt === expected, $sformatf("%s (expected=%b, got=%b)", msg, expected, intf.gnt));

    // Allow priority state to update
    @(posedge clk_i);
    #1;
  endtask

  // TEST CASES
  `include "Round_robin_tb/tc1.sv"
  `include "Round_robin_tb/tc2.sv"
  `include "Round_robin_tb/tc3.sv"
  `include "Round_robin_tb/tc4.sv"
  `include "Round_robin_tb/tc5.sv"
  `include "Round_robin_tb/tc6.sv"
  `include "Round_robin_tb/tc7.sv"
  `include "Round_robin_tb/tc8.sv"

  // MAIN INITIAL
  initial begin
    pass_count = 0;
    fail_count = 0;

    $timeformat(-9, 1, " ns", 20);
    $dumpfile("tb_round_robin_arbiter.vcd");
    $dumpvars(0, tb_round_robin_arbiter);

    // Initial reset: Clock is held idle, active-low reset asserted
    clk_i    = 0;
    arst_ni  = 0;
    intf.req = '0;
    #20;
    arst_ni  = 1;  // De-assert reset
    #20;

    // Start clock after reset
    start_clock();
    @(posedge clk_i);

    // Run all tests
    $display("Running all tests (1 through 8)...");
    tc1();
    tc2();
    tc3();
    tc4();
    tc5();
    tc6();
    tc7();
    tc8();

    // Summary
    $display("tb_round_robin_arbiter summary: pass=%0d fail=%0d", pass_count, fail_count);
    if (fail_count != 0) begin
      $fatal(1, "tb_round_robin_arbiter failed with %0d errors", fail_count);
    end
    $finish;
  end

endmodule
