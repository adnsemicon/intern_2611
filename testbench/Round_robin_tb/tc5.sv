// ============================================================
// TESTCASE 5: FAULT INJECTION & CHECKER VALIDATION
// ============================================================
//
// Objective:
// Deliberately inject a corrupted expected value to verify that
// the testbench checker detects the error, logs [FAIL], and
// report_summary() halts with $fatal.
//
// ============================================================

task automatic tc5();
    $display("\n==========================================");
    $display("       TESTCASE 5: FAULT INJECTION        ");
    $display("==========================================");

    apply_reset();

    // 1. Normal valid transaction (expected to PASS)
    apply_and_check(
        4'b0001,
        4'b0001,
        "TC5.1: Normal valid check"
    );

    // 2. Injected mismatch: core 1 requests, but core 3 expected (expected to FAIL)
    apply_and_check(
        4'b0010,
        4'b1000,
        "TC5.2: Deliberate fault injection"
    );

    $display("\n[TC5] Fault Injection Test Completed.\n");
endtask
