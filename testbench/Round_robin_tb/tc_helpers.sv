// ============================================================
// HELPERS for tc6 - tc11
// Include this file BEFORE tc6.sv ... tc11.sv
// ============================================================

// One arbitration cycle: apply r, then gnt_o is valid for this cycle
task automatic tc_drive(input logic [N-1:0] r);
    @(negedge intf.clk_i);
    intf.req_i = r;
    #1;
endtask

// Clear all requests
task automatic tc_idle();
    @(negedge intf.clk_i);
    intf.req_i = '0;
    #1;
endtask

function automatic logic [N-1:0] tc_onehot(input int k);
    tc_onehot    = '0;
    tc_onehot[k] = 1'b1;
endfunction

// One-hot vector -> master number (-1 if no bit is set)
function automatic int tc_idx(input logic [N-1:0] v);
    tc_idx = -1;
    for (int i = 0; i < N; i++)
        if (v[i] === 1'b1) tc_idx = i;
endfunction


// Silent on pass (keeps the log short in the big loops);
// a failure is reported through the normal check() task.
task automatic tc_chk(input logic ok, input string msg);
    if (ok) pass_count++;
    else    check(1'b0, msg);
endtask