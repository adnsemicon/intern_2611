// ============================================================
// TESTCASE 4: STARVATION PREVENTION & FAIRNESS
// ============================================================
//
// Objective:
// 1. Verify no requester can be starved.
// 2. Verify fair grant alternation under contention.
//
// ============================================================

task automatic tc4();

    $display("\n==========================================");
    $display("TESTCASE 4: STARVATION PREVENTION & FAIRNESS");
    $display("==========================================");

    // Part 1: No starvation
    repeat (5) begin
        apply_and_check(
            4'b0001,
            4'b0001,
            "TC4.1: M0 monopolizing bus"
        );
    end

    apply_and_check(
        4'b0011,
        4'b0010,
        "TC4.2: M1 wins, no starvation"
    );

    // Part 2: Fair alternation
    apply_and_check(
        4'b0011,
        4'b0001,
        "TC4.3: M0 gets next turn"
    );

    // Part 3: Restore M0 priority for TC5
    apply_and_check(4'b0010, 4'b0010, "TC4.4: M1 grant");
    apply_and_check(4'b0100, 4'b0100, "TC4.5: M2 grant");
    apply_and_check(4'b1000, 4'b1000, "TC4.6: M3 grant");

    tc_idle();

    $display("\n[TC4] Starvation Prevention & Fairness Test Completed.\n");

endtask