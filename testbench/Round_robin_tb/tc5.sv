// ============================================================
// TESTCASE 5: FAULT INJECTION & CHECKER VALIDATION
// ============================================================
//
// Objective:
// Demonstrate that the testbench self-checking mechanisms
// actually detect mismatches and prevent silent "false passes".
//
// Procedure:
// 1. Perform a valid transaction: request core 0, expect core 0.
//    Verifies that a correct DUT response passes the checker.
// 2. Perform fault injection: request core 1 (DUT outputs 4'b0010),
//    but intentionally provide a wrong expected value (4'b1000).
//    Verifies that the checker logs [FAIL], increments fail_count,
//    and report_summary() triggers $fatal.
//
// ============================================================

task automatic tc5();
    $display("\n========================================================");
    $display("    TESTCASE 5: FAULT INJECTION & CHECKER VALIDATION   ");
    $display("========================================================");
    $display("[INFO] Purpose: Deliberately inject corrupted expected values");
    $display("[INFO] to verify that the self-checking testbench detects failures,");
    $display("[INFO] logs [FAIL] with mismatch details, and halts with $fatal.\n");

    apply_reset();

    // --------------------------------------------------------
    // Step 1: Normal valid check (should PASS)
    // --------------------------------------------------------
    $display("[TC5.1] Step 1: Valid check (driving req=4'b0001, expecting gnt=4'b0001)...");
    apply_and_check(
        4'b0001,
        4'b0001,
        "TC5.1: Valid transaction (core 0 granted)"
    );

    // --------------------------------------------------------
    // Step 2: Fault Injection check (should FAIL)
    // --------------------------------------------------------
    $display("\n[TC5.2] Step 2: Injecting WRONG expected value!");
    $display("        Driving req=4'b0010 (DUT will output gnt=4'b0010)");
    $display("        Corrupted expected value injected: 4'b1000 (expecting core 3 instead of core 1)");

    apply_and_check(
        4'b0010,
        4'b1000,  // <-- INTENTIONAL MISMATCH INJECTION!
        "TC5.2: Injected fault check"
    );

    $display("\n[TC5] Fault Injection Test Completed.\n");
endtask
