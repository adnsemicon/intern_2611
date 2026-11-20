// ============================================================
// TESTCASE 9: ASYNCHRONOUS RESET DURING OPERATION
// ============================================================
// Objective:
// Reset asserted between two clock edges must restore the default
// order immediately, without waiting for a clock edge.
// ============================================================
task automatic tc9();

    $display("\n==========================================");
    $display("   TESTCASE 9: ASYNC RESET MID-OPERATION   ");
    $display("==========================================");

    apply_reset();

    // One grant: master 0 wins, the order now starts at master 1 (N >= 2)
    tc_drive('1);
    check(intf.gnt_o === tc_onehot(0), "TC9.1: master 0 granted before reset");

    // Let the clock edge pass so the order rotates, keep all requests high
    @(negedge intf.clk_i);
    intf.req_i = '1;

    // Assert reset in the middle of the cycle (no clock edge involved)
    intf.arst_ni = 1'b0;
    #1;
    check(intf.gnt_o === tc_onehot(0),
          "TC9.2: default order restored immediately, master 0 wins");

    // Release reset after a clock edge
    @(posedge intf.clk_i);
    @(negedge intf.clk_i);
    intf.arst_ni = 1'b1;
    intf.req_i   = '0;

    tc_drive('1);
    check(intf.gnt_o === tc_onehot(0), "TC9.3: master 0 wins after reset release");

    tc_idle();
    $display("\n[TC9] Async Reset Test Completed.\n");

endtask
