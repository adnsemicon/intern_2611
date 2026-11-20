// ============================================================
// TESTCASE 7: BACK-TO-BACK RESETS
// ============================================================
//
// Objective:
// Resets applied one after another, and a reset asserted while
// reset is already active, must leave the default order.
//

// ============================================================

task automatic tc7();

    $display("\n==========================================");
    $display("       TESTCASE 7: BACK-TO-BACK RESETS     ");
    $display("==========================================");

    // --------------------------------------------------------
    // Scenario A: two resets in a row after the order changed
    // --------------------------------------------------------
    apply_reset();
    tc_drive('1);
    tc_drive('1);                   // order has rotated

    apply_reset();
    apply_reset();

    tc_drive('1);
    check(intf.gnt_o === tc_onehot(0),
          "TC7.A: master 0 wins after two resets in a row");

    // --------------------------------------------------------
    // Scenario B: reset asserted again while already active
    // --------------------------------------------------------
    apply_reset();
    tc_drive('1);
    tc_drive('1);                   // order has rotated (requests still high)

    intf.arst_ni = 1'b0;            // reset
    #2;
    intf.arst_ni = 1'b0;            // asserted again while already active
    @(negedge intf.clk_i);
    intf.arst_ni = 1'b1;
    intf.req_i   = '0;

    tc_drive('1);
    check(intf.gnt_o === tc_onehot(0),
          "TC7.B: master 0 wins after reset asserted twice");

    tc_idle();
    $display("\n[TC7] Back-To-Back Resets Test Completed.\n");

endtask