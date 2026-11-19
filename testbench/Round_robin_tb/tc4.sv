// ============================================================
// TESTCASE 4: STARVATION PREVENTION AND FAIRNESS
// ============================================================
//
// Objective:
// Verify that an aggressive master holding a continuous request
// cannot monopolize the bus and starve other requesting masters.
// Ensures every requesting core is granted within at most N clock cycles.
//
// ============================================================

// Custom task: checks that victim core receives grant within bounded latency
task automatic check_no_starvation(
    input int aggressive_core = 0,
    input int victim_core = N - 1
);
    int wait_cycles;
    bit victim_granted;

    $display("[TC4] Testing starvation prevention: Core %0d (aggressive) vs Core %0d (victim)...",
             aggressive_core, victim_core);

    // 1. Give aggressive core an initial grant to advance priority
    @(negedge intf.clk_i);
    intf.req_i = (1 << aggressive_core);
    #1;
    check(intf.gnt_o === (1 << aggressive_core),
          $sformatf("Aggressive core %0d receives initial grant", aggressive_core));

    // 2. Victim asserts request while aggressive core STILL holds its request
    @(negedge intf.clk_i);
    intf.req_i = (1 << aggressive_core) | (1 << victim_core);

    wait_cycles = 0;
    victim_granted = 0;

    // Victim MUST be granted within at most N cycles (bounded latency)
    while (!victim_granted && wait_cycles < N) begin
        #1;
        if (intf.gnt_o[victim_core] === 1'b1) begin
            victim_granted = 1;
            $display("[INFO] Victim core %0d granted after %0d cycle(s) of waiting.",
                     victim_core, wait_cycles + 1);
        end else begin
            @(negedge intf.clk_i);
            wait_cycles++;
        end
    end

    check(victim_granted,
          $sformatf("Fairness verified: Core %0d granted within %0d cycles (no starvation)",
                    victim_core, wait_cycles + 1));

    // 3. Clear requests
    @(negedge intf.clk_i);
    intf.req_i = '0;
    #1;
endtask

// Main entry point for Testcase 4
task automatic tc4();
    $display("\n==========================================");
    $display("TESTCASE 4: STARVATION PREVENTION & FAIRNESS");
    $display("==========================================");
    apply_reset();
    check_no_starvation(0, N - 1);
    $display("\n[TC4] Starvation Prevention & Fairness Test Completed.\n");
endtask
