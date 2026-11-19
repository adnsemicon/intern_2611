// ============================================================
// TESTCASE 9: RANDOM REQUESTS WITH A REFERENCE MODEL
// ============================================================
// Objective:
// 21000 cycles of random requests (medium, high and low density).
// A small model of the order table predicts the grant each cycle.
// ============================================================
task automatic tc9();
    logic [N-1:0] r, exp_g;
    int           model [N];
    int           tmp   [N];
    int           pos;

    $display("\n==========================================");
    $display("   TESTCASE 9: RANDOM WITH REFERENCE MODEL");
    $display("==========================================");

    apply_reset();
    for (int i = 0; i < N; i++) model[i] = i;

    for (int c = 0; c < 21000; c++) begin
        if      (c < 7000)  r = $urandom;                        // medium density
        else if (c < 14000) r = $urandom | $urandom;             // many requests
        else                r = $urandom & $urandom & $urandom;  // few requests

        tc_drive(r);

        // expected grant from the model
        exp_g = '0;
        pos   = -1;
        for (int i = 0; i < N; i++)
            if (exp_g == '0 && r[model[i]]) begin
                exp_g[model[i]] = 1'b1;
                pos = i;
            end

        tc_chk(intf.gnt_o === exp_g,
              $sformatf("TC9: cycle %0d req=%b : expected %b, got %b", c, r, exp_g, intf.gnt_o));

        // rotate the model, as the clock edge will rotate the design
        if (pos >= 0) begin
            for (int i = 0; i < N; i++) tmp[i] = model[(i + pos + 1) % N];
            for (int i = 0; i < N; i++) model[i] = tmp[i];
        end
    end

    tc_idle();
    $display("\n[TC9] Random Test Completed.\n");

endtask