// ============================================================
// TESTCASE 4: PRIORITY PRESERVATION
// ============================================================
//
// Objective:
// Verify that the priority sequence remains unchanged
// when there are no active requests.
//
// ============================================================

task automatic tc4();

    $display("\n==========================================");
    $display("      TESTCASE 4: PRIORITY PRESERVATION   ");
    $display("==========================================");

    // ========================================================
    // SCENARIO A:
    // Priority preservation immediately after reset
    // ========================================================

    apply_reset();

    $display("\n[TC4] Scenario A: Idle after reset");

    // No requests for 5 clock cycles
    repeat (5) begin

        apply_and_check(
            4'b0000,
            4'b0000,
            "TC4.A: No requests during idle"
        );

    end

    // Initial priority must remain unchanged
    // Master 0 should still have highest priority

    apply_and_check(
        4'b1111,
        4'b0001,
        "TC4.A: Priority preserved after idle"
    );


    // ========================================================
    // SCENARIO B:
    // Priority preservation after Master 0 wins
    // ========================================================

    apply_reset();

    $display("\n[TC4] Scenario B: Idle after Master 0 grant");

    // Master 0 gets grant
    // Expected new priority: 1 > 2 > 3 > 0

    apply_and_check(
        4'b0001,
        4'b0001,
        "TC4.B: Master 0 receives grant"
    );

    // Idle for 5 clock cycles
    repeat (5) begin

        apply_and_check(
            4'b0000,
            4'b0000,
            "TC4.B: No requests during idle"
        );

    end

    // Priority should still be: 1 > 2 > 3 > 0
    // When all request, Master 1 must win

    apply_and_check(
        4'b1111,
        4'b0010,
        "TC4.B: Priority preserved, Master 1 wins"
    );


    // ========================================================
    // SCENARIO C:
    // Priority preservation after Master 2 wins
    // ========================================================

    apply_reset();

    $display("\n[TC4] Scenario C: Idle after Master 2 grant");

    // Master 2 receives grant
    // Expected new priority: 3 > 0 > 1 > 2

    apply_and_check(
        4'b0100,
        4'b0100,
        "TC4.C: Master 2 receives grant"
    );

    // Idle for 5 clock cycles
    repeat (5) begin

        apply_and_check(
            4'b0000,
            4'b0000,
            "TC4.C: No requests during idle"
        );

    end

    // Priority should remain: 3 > 0 > 1 > 2
    // Master 3 must win when everyone requests

    apply_and_check(
        4'b1111,
        4'b1000,
        "TC4.C: Priority preserved, Master 3 wins"
    );

    $display("\n[TC4] Priority Preservation Test Completed.\n");

endtask
