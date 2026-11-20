// ============================================================
// TESTCASE 2: PRIORITY PRESERVATION
// ============================================================
//
// Objective:
// Verify that the priority sequence remains unchanged
// when there are no active requests.
//
// ============================================================

task automatic tc2();

    $display("\n==========================================");
    $display(" TESTCASE 2: PRIORITY PRESERVATION ");
    $display("==========================================");

    // Scenario A: Idle with initial priority
    $display("\n[TC2] Scenario A");

    repeat (5)
        apply_and_check(4'b0000, 4'b0000, "TC2.A: Idle");

    apply_and_check(4'b1111, 4'b0001, "TC2.A: M0 wins");

    // Scenario B: Idle after M0 grant
    $display("\n[TC2] Scenario B");

    apply_and_check(4'b0001, 4'b0001, "TC2.B: M0 grant");

    repeat (5)
        apply_and_check(4'b0000, 4'b0000, "TC2.B: Idle");

    apply_and_check(4'b1111, 4'b0010, "TC2.B: M1 wins");

    // Scenario C: Idle after M2 grant
    $display("\n[TC2] Scenario C");

    apply_and_check(4'b0100, 4'b0100, "TC2.C: M2 grant");

    repeat (5)
        apply_and_check(4'b0000, 4'b0000, "TC2.C: Idle");

    apply_and_check(4'b1111, 4'b1000, "TC2.C: M3 wins");

    $display("\n[TC2] Priority Preservation Test Completed.\n");

endtask