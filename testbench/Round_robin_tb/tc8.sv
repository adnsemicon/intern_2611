// ============================================================
// TESTCASE 8: NO X OR Z ON THE GRANT OUTPUT
// ============================================================
//
// Objective:
// After reset, gnt_o must never contain X or Z, with or without
// requests, including random request patterns.
//
// Needs: tc_helpers.sv
//
// ============================================================

task automatic tc8();
    logic [N-1:0] r;

    $display("\n==========================================");
    $display("      TESTCASE 8: NO X/Z ON GRANT OUTPUT   ");
    $display("==========================================");

    apply_reset();

    // Right after reset, no requests
    tc_drive('0);
    check(!$isunknown(intf.gnt_o), "TC8.1: gnt_o is known after reset with no request");

    // Random requests
    for (int c = 0; c < 2000; c++) begin
        r = $urandom;
        tc_drive(r);
        tc_chk(!$isunknown(intf.gnt_o),
               $sformatf("TC8: cycle %0d req=%b : gnt_o has X/Z (%b)", c, r, intf.gnt_o));
    end

    tc_idle();
    $display("\n[TC8] No X/Z Test Completed.\n");

endtask