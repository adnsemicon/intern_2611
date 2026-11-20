// ============================================================
// TESTCASE 3: PRIORITY SELECTION
// ============================================================
//
// Objective:
// Verify that the arbiter selects the highest-priority
// requesting master according to the initial priority order.
//
// Initial Priority:
// Master 0 > Master 1 > Master 2 > Master 3
//
// ============================================================

task automatic tc3();

    $display("\n==========================================");
    $display("       TESTCASE 3: PRIORITY SELECTION     ");
    $display("==========================================");

    // --------------------------------------------------------
    // Test 1: Only Master 0 requests
    // --------------------------------------------------------
    apply_reset();

    apply_and_check(
        4'b0001,
        4'b0001,
        "TC3.1: Only Master 0 requests"
    );

    // --------------------------------------------------------
    // Test 2: Only Master 1 requests
    // --------------------------------------------------------
    apply_reset();

    apply_and_check(
        4'b0010,
        4'b0010,
        "TC3.2: Only Master 1 requests"
    );

    // --------------------------------------------------------
    // Test 3: Only Master 2 requests
    // --------------------------------------------------------
    apply_reset();

    apply_and_check(
        4'b0100,
        4'b0100,
        "TC3.3: Only Master 2 requests"
    );

    // --------------------------------------------------------
    // Test 4: Only Master 3 requests
    // --------------------------------------------------------
    apply_reset();

    apply_and_check(
        4'b1000,
        4'b1000,
        "TC3.4: Only Master 3 requests"
    );

    // --------------------------------------------------------
    // Test 5: All masters request
    // Highest priority Master 0 must win
    // --------------------------------------------------------
    apply_reset();

    apply_and_check(
        4'b1111,
        4'b0001,
        "TC3.5: All masters request, Master 0 wins"
    );

    // --------------------------------------------------------
    // Test 6: Masters 1, 2, 3 request
    // Master 1 has highest priority
    // --------------------------------------------------------
    apply_reset();

    apply_and_check(
        4'b1110,
        4'b0010,
        "TC3.6: Masters 1,2,3 request, Master 1 wins"
    );

    // --------------------------------------------------------
    // Test 7: Masters 2 and 3 request
    // Master 2 has higher priority
    // --------------------------------------------------------
    apply_reset();

    apply_and_check(
        4'b1100,
        4'b0100,
        "TC3.7: Masters 2,3 request, Master 2 wins"
    );

    // --------------------------------------------------------
    // Test 8: Masters 1 and 3 request
    // Master 1 has higher priority
    // --------------------------------------------------------
    apply_reset();

    apply_and_check(
        4'b1010,
        4'b0010,
        "TC3.8: Masters 1,3 request, Master 1 wins"
    );

    // --------------------------------------------------------
    // Test 9: Masters 0 and 3 request
    // Master 0 has higher priority
    // --------------------------------------------------------
    apply_reset();

    apply_and_check(
        4'b1001,
        4'b0001,
        "TC3.9: Masters 0,3 request, Master 0 wins"
    );

    // --------------------------------------------------------
    // Test 10: Masters 1 and 2 request
    // Master 1 has higher priority
    // --------------------------------------------------------
    apply_reset();

    apply_and_check(
        4'b0110,
        4'b0010,
        "TC3.10: Masters 1,2 request, Master 1 wins"
    );

    $display("\n[TC3] Priority Selection Test Completed.\n");

endtask
