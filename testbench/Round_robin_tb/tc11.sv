// ============================================================
// TESTCASE 11: PRIORITY SELECTION IN EVERY TABLE STATE (EXHAUSTIVE)
// ============================================================
// Objective:
// Every request pattern (2^N) in every table state (order starting
// at master 0, 1, ..., N-1). The winner must be the first requesting
// master when scanning cyclically from the first master in the order.
// ============================================================
task automatic tc11();
    logic [N-1:0] exp_g;
    logic [N-1:0] pat;

    $display("\n==========================================");
    $display("  TESTCASE 11: EVERY PATTERN, EVERY STATE  ");
    $display("==========================================");

    if (N <= 10) begin
        for (int s = 0; s < N; s++) begin
            for (int p = 0; p < (1 << N); p++) begin
                apply_reset();
                if (s > 0) tc_drive(tc_onehot(s - 1));   // grant master s-1: order now starts at s

                pat = p;
                tc_drive(pat);

                exp_g = '0;
                for (int k = 0; k < N; k++)
                    if (exp_g == '0 && pat[(s + k) % N])
                        exp_g[(s + k) % N] = 1'b1;

                tc_chk(intf.gnt_o === exp_g,
                      $sformatf("TC11: order starts at %0d, req=%b : expected %b, got %b",
                                s, pat, exp_g, intf.gnt_o));
            end
        end
    end else begin
        $display("[TC11] Skipped: N=%0d is too large for the exhaustive test.", N);
    end

    tc_idle();
    $display("\n[TC11] Exhaustive Priority Selection Test Completed.\n");

endtask