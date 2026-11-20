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
    $display("    TESTCASE 1: SEQUENTIAL STATE ROTATION ");
    $display("==========================================");

    // Initial reset to establish known starting order: [0, 1, 2, 3]
    apply_reset();

    // --------------------------------------------------------
    // Step 1: Only Master 0 requests -> M0 granted
    // State rotates to: Master 1 > Master 2 > Master 3 > Master 0
    // --------------------------------------------------------
    apply_and_check(
        4'b0001,
        4'b0001,
        "TC1.1: Only Master 0 requests, Master 0 granted"
    );

    // --------------------------------------------------------
    // Step 2: Only Master 1 requests -> M1 granted
    // State rotates to: Master 2 > Master 3 > Master 0 > Master 1
    // --------------------------------------------------------
    apply_and_check(
        4'b0010,
        4'b0010,
        "TC1.2: Only Master 1 requests, Master 1 granted"
    );

    // --------------------------------------------------------
    // Step 3: Only Master 2 requests -> M2 granted
    // State rotates to: Master 3 > Master 0 > Master 1 > Master 2
    // --------------------------------------------------------
    apply_and_check(
        4'b0100,
        4'b0100,
        "TC1.3: Only Master 2 requests, Master 2 granted"
    );

    // --------------------------------------------------------
    // Step 4: Only Master 3 requests -> M3 granted
    // State rotates to: Master 0 > Master 1 > Master 2 > Master 3 (full wrap)
    // --------------------------------------------------------
    apply_and_check(
        4'b1000,
        4'b1000,
        "TC1.4: Only Master 3 requests, Master 3 granted"
    );

    // --------------------------------------------------------
    // Step 5: All masters request (4'b1111)
    // Current priority: M0 > M1 > M2 > M3 -> Master 0 wins
    // State rotates to: Master 1 > Master 2 > Master 3 > Master 0
    // --------------------------------------------------------
    apply_and_check(
        4'b1111,
        4'b0001,
        "TC1.5: All masters request, Master 0 wins"
    );

    // --------------------------------------------------------
    // Step 6: Masters 1, 2, 3 request (4'b1110)
    // Current priority: M1 > M2 > M3 > M0 -> Master 1 wins
    // State rotates to: Master 2 > Master 3 > Master 0 > Master 1
    // --------------------------------------------------------
    apply_and_check(
        4'b1110,
        4'b0010,
        "TC1.6: Masters 1,2,3 request, Master 1 wins"
    );

    // --------------------------------------------------------
    // Step 7: Masters 2 and 3 request (4'b1100)
    // Current priority: M2 > M3 > M0 > M1 -> Master 2 wins
    // State rotates to: Master 3 > Master 0 > Master 1 > Master 2
    // --------------------------------------------------------
    apply_and_check(
        4'b1100,
        4'b0100,
        "TC1.7: Masters 2,3 request, Master 2 wins"
    );

    // --------------------------------------------------------
    // Step 8: Masters 1 and 3 request (4'b1010)
    // Current priority: M3 > M0 > M1 > M2 -> Master 3 wins due to rotation!
    // State rotates to: Master 0 > Master 1 > Master 2 > Master 3
    // --------------------------------------------------------
    apply_and_check(
        4'b1010,
        4'b1000,
        "TC1.8: Masters 1,3 request, Master 3 wins (rotated priority: M3 > M0 > M1 > M2)"
    );

    // --------------------------------------------------------
    // Step 9: Masters 0 and 3 request (4'b1001)
    // Current priority: M0 > M1 > M2 > M3 -> Master 0 wins
    // State rotates to: Master 1 > Master 2 > Master 3 > Master 0
    // --------------------------------------------------------
    apply_and_check(
        4'b1001,
        4'b0001,
        "TC1.9: Masters 0,3 request, Master 0 wins"
    );

    // --------------------------------------------------------
    // Step 10: Masters 1 and 2 request (4'b0110)
    // Current priority: M1 > M2 > M3 > M0 -> Master 1 wins
    // State rotates to: Master 2 > Master 3 > Master 0 > Master 1
    // --------------------------------------------------------
    apply_and_check(
        4'b0110,
        4'b0010,
        "TC1.10: Masters 1,2 request, Master 1 wins"
    );

    $display("\n[TC1] Sequential State Rotation Test Completed.\n");

endtask
