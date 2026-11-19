// ============================================================
// TESTCASE 3: FULL ROTATION AND WRAP-AROUND
// ============================================================
//
// Objective:
// Assert requests for all cores simultaneously (req_i = '1).
// Verify that the arbiter grants each core in round-robin order:
//   Core 0 -> Core 1 -> Core 2 -> ... -> Core N-1 -> Core 0 (wrap-around)
// Repeats for multiple rounds to ensure pointer never freezes or skips.
//
// ============================================================

// Custom task specific to this test case
task automatic verify_rotation(input int num_rounds = 2);
    logic [N-1:0] expected_gnt;
    $display("[TC3] Verifying %0d complete round-robin rotations for N=%0d cores...", num_rounds, N);

    @(negedge intf.clk_i);
    intf.req_i = '1; // All cores requesting simultaneously

    for (int round = 0; round < num_rounds; round++) begin
        for (int core = 0; core < N; core++) begin
            expected_gnt = (1 << core);
            #1; // Allow combinational logic to settle
            check(intf.gnt_o === expected_gnt,
                  $sformatf("Rotation round %0d: expected core %0d grant (%b), got %b",
                            round, core, expected_gnt, intf.gnt_o));
            @(negedge intf.clk_i); // Advance to next clock cycle
        end
    end

    intf.req_i = '0;
    #1;
endtask

// Main entry point for Testcase 3
task automatic tc3();
    $display("\n==========================================");
    $display("  TESTCASE 3: FULL ROTATION & WRAP-AROUND ");
    $display("==========================================");
    apply_reset();
    verify_rotation(2);
    $display("\n[TC3] Full Rotation & Wrap-Around Test Completed.\n");
endtask
