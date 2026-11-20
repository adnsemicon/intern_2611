// ============================================================
// TESTCASE 1: SEQUENTIAL STATE ROTATION
// ============================================================
//
// Objective:
// Verify that consecutive requests without intermediate resets
// dynamically rotate the arbiter priority pointer across grant
// cycles according to the round-robin scheme.
//
// Initial Priority:
// Master 0 > Master 1 > Master 2 > Master 3
//
// ============================================================


task automatic tc1();

    $display("\n==========================================");
    $display(" TESTCASE 1: SEQUENTIAL STATE ROTATION ");
    $display("==========================================");

    // Single-request rotation
    apply_and_check(4'b0001, 4'b0001, "TC1.1: M0 granted");
    apply_and_check(4'b0010, 4'b0010, "TC1.2: M1 granted");
    apply_and_check(4'b0100, 4'b0100, "TC1.3: M2 granted");
    apply_and_check(4'b1000, 4'b1000, "TC1.4: M3 granted");

    // Multi-request rotation
    apply_and_check(4'b1111, 4'b0001, "TC1.5: All request, M0 wins");
    apply_and_check(4'b1110, 4'b0010, "TC1.6: M1 wins");
    apply_and_check(4'b1100, 4'b0100, "TC1.7: M2 wins");
    apply_and_check(4'b1010, 4'b1000, "TC1.8: M3 wins");

    apply_and_check(4'b1001, 4'b0001, "TC1.9: M0 wins");
    apply_and_check(4'b0110, 4'b0010, "TC1.10: M1 wins");
    apply_and_check(4'b1100, 4'b0100, "TC1.11: M2 wins");
    apply_and_check(4'b1001, 4'b1000, "TC1.12: M3 wins");

    $display("\n[TC1] Sequential State Rotation Test Completed.\n");

endtask