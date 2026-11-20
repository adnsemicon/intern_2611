// ============================================================
// TESTCASE 5: REQUEST GLITCH BETWEEN CLOCK EDGES
// ============================================================
//
// Objective:
// A request that rises and falls between two rising clock edges
// must not rotate the priority order. The order may only change
// when a grant is present at a rising edge.
//
// Assumes the clock half period is > 3 ns.
//
// ============================================================

task automatic tc5();

    $display("\n==========================================");
    $display("   TESTCASE 5: REQUEST GLITCH BETWEEN EDGES");
    $display("==========================================");

    // Raise all requests at the falling edge and look at the grant
    @(negedge intf.clk_i);
    intf.req_i = '1;
    #1;
    check(intf.gnt_o === tc_onehot(0),
          "TC5.1: master 0 is granted while the requests are high");

    // Drop all requests 2 ns later, before the next rising edge
    #2;
    intf.req_i = '0;
    @(posedge intf.clk_i);          // this rising edge sees no request
    #1;

    // Request again. If the glitch had rotated the order, another master would win
    tc_drive('1);
    check(intf.gnt_o === tc_onehot(0),
          "TC5.2: order unchanged, master 0 wins again");

    tc_idle();
    $display("\n[TC5] Request Glitch Test Completed.\n");

endtask
