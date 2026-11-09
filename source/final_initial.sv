module final_initial;

logic clk;
logic rst_n;
int pass_count = 0;
int fail_count = 0;

 initial begin
  $display("[%0t] Simulation initiated.", $time);
  clk = 1'b0;
  rst_n = 1'b0;
  #20 rst_n = 1'b1;  // De-assert reset after 20ns
 end

 // 2. Final Block: Runs ONCE at the very end of simulation (upon $finish)
 // Executes in zero simulation time. Ideal for scoreboard summary reporting.
 final begin
  $display("========================================");
  $display("  TEST SUMMARY: %0d Passed, %0d Failed", pass_count, fail_count);
  $display("========================================");
 end

endmodule