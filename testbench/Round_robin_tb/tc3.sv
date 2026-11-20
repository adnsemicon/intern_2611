// ============================================================
// TESTCASE 3: FULL ROTATION & WRAP-AROUND
// ============================================================
//
// Objective:
// When all masters request simultaneously (req_i = 4'b1111),
// verify that the arbiter grants each master one by one in order:
// Master 0 -> Master 1 -> Master 2 -> Master 3 -> Wrap to Master 0.
// Tested across 2 complete rounds (8 cycles total).
//
// ============================================================

task automatic tc3();

    $display("\n==========================================");
    $display(" TESTCASE 3: FULL ROTATION & WRAP-AROUND ");
    $display("==========================================");

    // ----------------------------------------------------
    // Round 1: Full rotation through all 4 masters
    // ----------------------------------------------------
    apply_and_check(4'b1111, 4'b0001, "TC3.1: Round 1 - Master 0 grant");
    apply_and_check(4'b1111, 4'b0010, "TC3.2: Round 1 - Master 1 grant");
    apply_and_check(4'b1111, 4'b0100, "TC3.3: Round 1 - Master 2 grant");
    apply_and_check(4'b1111, 4'b1000, "TC3.4: Round 1 - Master 3 grant");

    // ----------------------------------------------------
    // Round 2: Wrap-around verification back to Master 0
    // ----------------------------------------------------
    apply_and_check(4'b1111, 4'b0001, "TC3.5: Round 2 - Wrap back to Master 0");
    apply_and_check(4'b1111, 4'b0010, "TC3.6: Round 2 - Master 1 grant");
    apply_and_check(4'b1111, 4'b0100, "TC3.7: Round 2 - Master 2 grant");
    apply_and_check(4'b1111, 4'b1000, "TC3.8: Round 2 - Master 3 grant");

    tc_idle();

    $display("\n[TC3] Full Rotation & Wrap-Around Test Completed.\n");

endtask
