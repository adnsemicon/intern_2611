`timescale 1ns/1ps

module tb_rr_arbiter;

  localparam int N = 32;

  logic         clk_i;
  logic         arst_ni;
  logic [N-1:0] req_i;
  logic [N-1:0] gnt_o;

  real period = 10.0;

  round_robin_arbiter #(.N(N)) dut (
    .clk_i   (clk_i),
    .arst_ni (arst_ni),
    .req_i   (req_i),
    .gnt_o   (gnt_o)
  );

  // ------------------------------------------------------------------
  // Clock and Reset Generation / Driver Tasks
  // ------------------------------------------------------------------
  initial begin
    clk_i   = 0;
    arst_ni = 1;
    req_i   = 0;
  end

  bit clk_en = 0;
  initial begin
    wait (clk_en);
    forever #(period/2) clk_i = ~clk_i;
  end

  // free-running clock, started by apply_reset
  task automatic start_clk();
    clk_en = 1;
  endtask

  // reset with NO clock, release it, wait 'delay' ns, then start the clock
  task automatic apply_reset(input int hold = 25, input int delay = 13);
    req_i = 0;
    #1;                  // avoid time-0 race with the DUT always_ff
    arst_ni = 0;
    #(hold);
    arst_ni = 1;
    #(delay);
    start_clk();
  endtask

  // async reset pulse while the clock is running
  task automatic async_reset(input int width = 7);
    arst_ni = 0;
    #(width);
    arst_ni = 1;
  endtask

  // set req_i at the falling edge -> DUT samples it on the next rising edge
  task automatic drive(input logic [N-1:0] r);
    @(negedge clk_i);
    req_i = r;
  endtask

  // ------------------------------------------------------------------
  // Reference model + checker (checks gnt_o on every clock edge)
  // order[0] = highest priority. Winner moves to the end.
  // ------------------------------------------------------------------
  int           order [N];
  int           tmp   [N];
  int           win;
  int           errors = 0;
  logic [N-1:0] exp_g;

  function automatic logic [N-1:0] exp_gnt(input logic [N-1:0] req);
    logic [N-1:0] g;
    g = '0;
    for (int i = 0; i < N; i++)
      if (req[order[i]] && g == '0)
        g[order[i]] = 1'b1;
    return g;
  endfunction

  always @(posedge clk_i or negedge arst_ni) begin
    if (!arst_ni) begin
      for (int i = 0; i < N; i++) order[i] = i;
    end
    else begin
      exp_g = exp_gnt(req_i);
      if (gnt_o !== exp_g) begin
        errors++;
        $display("[%0t] ERROR: req=%b exp_gnt=%b got_gnt=%b", $time, req_i, exp_g, gnt_o);
      end
      if (|req_i) begin
        for (int i = 0; i < N; i++)
          if (exp_g[order[i]]) win = i;
        for (int i = 0; i < N; i++)
          tmp[i] = order[(i + win + 1) % N];
        for (int i = 0; i < N; i++)
          order[i] = tmp[i];
      end
    end
  end

  // check gnt_o 1ns after req_i changed (before the next clock edge)
  task automatic check_gnt(input logic [N-1:0] e);
    #1;
    if (gnt_o !== e) begin
      errors++;
      $display("[%0t] ERROR: req=%b expected gnt=%b got gnt=%b", $time, req_i, e, gnt_o);
    end
  endtask

  // ------------------------------------------------------------------
  // TEST 1: reset / power-up
  // ------------------------------------------------------------------
  task automatic test1_reset();
    $display("TEST 1: reset / power-up");
    drive('0);
    check_gnt('0);
    drive('1);
    check_gnt(1);            // after reset master 0 wins
  endtask

  // ------------------------------------------------------------------
  // TEST 2: single requester sweep, then all request -> winner is k+1
  // ------------------------------------------------------------------
  task automatic test2_single();
    $display("TEST 2: single requester sweep");
    for (int k = 0; k < N; k++) begin
      repeat (3) begin
        drive(1 << k);
        check_gnt(1 << k);
      end
      drive('1);
      check_gnt(1 << ((k + 1) % N));
    end
  endtask

  // ------------------------------------------------------------------
  // TEST 3: all request -> grants rotate 0,1,2..N-1,0,1...
  // ------------------------------------------------------------------
  task automatic test3_rotation();
    $display("TEST 3: full rotation");
    drive('0);
    async_reset(2);
    for (int c = 0; c < 4 * N; c++) begin
      drive('1);
      check_gnt(1 << (c % N));
    end
  endtask

  // ------------------------------------------------------------------
  // TEST 4: idle must not change priority
  // ------------------------------------------------------------------
  task automatic test4_idle();
    int k;
    $display("TEST 4: idle holds priority");
    for (int t = 0; t < 8; t++) begin
      k = $urandom_range(0, N - 1);
      drive(1 << k);
      check_gnt(1 << k);
      repeat ($urandom_range(1, 30)) begin
        drive('0);
        check_gnt('0);
      end
      drive('1);
      check_gnt(1 << ((k + 1) % N));
    end
  endtask

  // ------------------------------------------------------------------
  // TEST 5: every priority position x request masks (exhaustive if N<=10, sampled if N>10)
  // ------------------------------------------------------------------
  task automatic test5_exhaustive();
    logic [N-1:0] mask, e;
    $display("TEST 5: priority position x mask");
    for (int p = 0; p < N; p++) begin
      if (N <= 10) begin
        for (int m = 1; m < (1 << N); m++) begin
          mask = m;
          drive('0);
          async_reset(2);                      // priority back to 0
          if (p != 0) drive(1 << ((p + N - 1) % N));   // winner p-1 -> p is highest
          drive(mask);
          e = '0;                                  // first set bit at or after p
          for (int j = 0; j < N; j++)
            if (mask[(p + j) % N] && e == '0)
              e[(p + j) % N] = 1'b1;
          check_gnt(e);
        end
      end else begin
        repeat (100) begin
          do mask = $urandom; while (mask == '0);
          drive('0);
          async_reset(2);                      // priority back to 0
          if (p != 0) drive(1 << ((p + N - 1) % N));   // winner p-1 -> p is highest
          drive(mask);
          e = '0;                                  // first set bit at or after p
          for (int j = 0; j < N; j++)
            if (mask[(p + j) % N] && e == '0)
              e[(p + j) % N] = 1'b1;
          check_gnt(e);
        end
      end
    end
  endtask

  // ------------------------------------------------------------------
  // TEST 6: starvation - victim always requests, wait must be <= N-1
  // ------------------------------------------------------------------
  task automatic test6_starvation();
    logic [N-1:0] r;
    int wait_cnt, max_wait;
    $display("TEST 6: starvation bound");
    for (int v = 0; v < N; v++) begin
      wait_cnt = 0;
      max_wait = 0;
      repeat (300) begin
        if ($urandom_range(0, 1)) r = '1;
        else                      r = $urandom;
        r[v] = 1'b1;
        drive(r);
        #1;
        if (gnt_o[v]) wait_cnt = 0;
        else begin
          wait_cnt++;
          if (wait_cnt > max_wait) max_wait = wait_cnt;
        end
      end
      if (max_wait > N - 1) begin
        errors++;
        $display("ERROR: master %0d waited %0d cycles", v, max_wait);
      end
    end
  endtask

  // ------------------------------------------------------------------
  // TEST 7: random traffic (checker does the comparison)
  // ------------------------------------------------------------------
  task automatic test7_random();
    logic [N-1:0] r;
    int mode;
    $display("TEST 7: random traffic");
    repeat (200) begin
      mode = $urandom_range(0, 3);
      repeat (100) begin
        case (mode)
          0: r = $urandom;                              // random
          1: begin r = '0; r[$urandom_range(0, N-1)] = 1; end   // sparse
          2: begin r = '1; r[$urandom_range(0, N-1)] = 0; end   // dense
          3: r = $urandom & $urandom & $urandom;        // mostly idle
        endcase
        drive(r);
      end
    end
  endtask

  // ------------------------------------------------------------------
  // TEST 8: async reset in the middle of operation (not clock aligned)
  // ------------------------------------------------------------------
  task automatic test8_mid_reset();
    logic [N-1:0] r, e;
    $display("TEST 8: async reset during operation");
    for (int t = 0; t < 30; t++) begin
      r = $urandom_range(1, (1 << N) - 1);
      drive(r);
      #($urandom_range(1, 8) + 0.05);        // random point inside the cycle
      arst_ni = 0;
      e = '0;                                // in reset: lowest requester wins
      for (int i = N - 1; i >= 0; i--)
        if (r[i]) begin e = '0; e[i] = 1'b1; end
      check_gnt(e);
      #($urandom_range(1, 6));
      arst_ni = 1;
      repeat (3) drive($urandom);
    end
  endtask

  // ------------------------------------------------------------------
  // TEST 9: req_i changes several times inside one cycle
  // gnt_o must follow, only the value at the clock edge rotates priority
  // ------------------------------------------------------------------
  task automatic test9_comb();
    logic [N-1:0] r1, r2, r3;
    $display("TEST 9: combinational path / edge sampling");
    for (int t = 0; t < 200; t++) begin
      @(negedge clk_i);
      r1 = $urandom;  req_i = r1;  check_gnt(exp_gnt(r1));
      r2 = $urandom;  req_i = r2;  check_gnt(exp_gnt(r2));
      r3 = $urandom;  req_i = r3;  check_gnt(exp_gnt(r3));
    end
  endtask

  // ------------------------------------------------------------------
  // Main
  // ------------------------------------------------------------------
  initial begin
    apply_reset(25, 13);      // reset first, clock starts 13ns after release

    test1_reset();
    test2_single();
    test3_rotation();
    test4_idle();
    test5_exhaustive();
    test6_starvation();
    test7_random();
    test8_mid_reset();
    test9_comb();

    drive('0);
    drive('0);
    if (errors == 0) $display("*** ALL TESTS PASSED ***");
    else             $display("*** FAILED: %0d errors ***", errors);
    $finish;
  end

endmodule
