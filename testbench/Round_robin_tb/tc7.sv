// ============================================================
// TESTCASE 7: NO X OR Z ON THE GRANT OUTPUT
// ============================================================
//
// Objective:
// After reset, gnt_o must never contain X or Z, with or without
// requests, including random request patterns.
//
// ============================================================

task automatic tc7();
    logic [N-1:0] r;

    $display("\n==========================================");
    $display("      TESTCASE 7: NO X/Z ON GRANT OUTPUT   ");
    $display("==========================================");

    // Initial check with no requests
    tc_drive('0);
    check(!$isunknown(intf.gnt_o), "TC7.1: gnt_o is known with no request");

    // Random requests
    for (int c = 0; c < 2000; c++) begin
        r = $urandom;
        tc_drive(r);
        tc_chk(!$isunknown(intf.gnt_o),
               $sformatf("TC7: cycle %0d req=%b : gnt_o has X/Z (%b)", c, r, intf.gnt_o));
    end

    tc_idle();
    $display("\n[TC7] No X/Z Test Completed.\n");

endtask
