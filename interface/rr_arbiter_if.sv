`timescale 1ns/1ps

// Interface for round_robin_arbiter (match N with the DUT parameter)
interface rr_arbiter_if #(parameter int N = 8);

  logic         clk_i;
  logic         arst_ni;
  logic [N-1:0] req_i;
  logic [N-1:0] gnt_o;

  real period = 10.0;

  initial begin
    clk_i   = 0;
    arst_ni = 1;
    req_i   = 0;
  end

  // free-running clock, started by apply_reset
  task start_clk();
    fork
      forever #(period/2) clk_i = ~clk_i;
    join_none
  endtask

  // reset with NO clock, release it, wait 'delay' ns, then start the clock
  task apply_reset(input int hold = 25, input int delay = 13);
    req_i = 0;
    #1;                  // avoid time-0 race with the DUT always_ff
    arst_ni = 0;
    #(hold);
    arst_ni = 1;
    #(delay);
    start_clk();
  endtask

  // async reset pulse while the clock is running
  task async_reset(input int width = 7);
    arst_ni = 0;
    #(width);
    arst_ni = 1;
  endtask

  // set req_i at the falling edge -> DUT samples it on the next rising edge
  task drive(input logic [N-1:0] r);
    @(negedge clk_i);
    req_i = r;
  endtask

endinterface
