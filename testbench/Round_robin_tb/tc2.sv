task automatic check_no_starvation(
 input int persistent_master = 0,
 input int competing_master  = N - 1
);

 int wait_cycles;
 bit competing_granted;
 logic [N-1:0] check_expected;

 $display("[TC2] Testing starvation prevention: Master %0d (persistent) vs Master %0d (competing)...",
          persistent_master, competing_master);

 @(negedge intf.clk_i);

 intf.req_i = (1 << persistent_master);

 #1;

 check_expected = (ERROR_INJECT) ? ~(1 << persistent_master)
                                 :  (1 << persistent_master);

 check(intf.gnt_o === check_expected,
       $sformatf("Persistent master %0d receives initial grant%s",
                 persistent_master,
                 ERROR_INJECT ? " [FAULT INJECTED]" : ""));

 @(negedge intf.clk_i);

 intf.req_i = (1 << persistent_master) |
              (1 << competing_master);

 wait_cycles      = 0;
 competing_granted = 0;

 while (!competing_granted && wait_cycles < N) begin

   #1;

   if (intf.gnt_o[competing_master] === 1'b1) begin
     competing_granted = 1;

     $display("[INFO] Competing master %0d granted after %0d cycle(s) of waiting.",
              competing_master, wait_cycles + 1);
   end
   else begin
     @(negedge intf.clk_i);
     wait_cycles++;
   end

 end

 check((ERROR_INJECT) ? !competing_granted : competing_granted,
       $sformatf("Fairness verified: Master %0d granted within %0d cycles (no starvation)%s",
                 competing_master,
                 wait_cycles + 1,
                 ERROR_INJECT ? " [FAULT INJECTED]" : ""));

 @(negedge intf.clk_i);

 intf.req_i = '0;

 #1;

endtask


task automatic tc2();

 $display("\n==========================================");
 $display("TESTCASE 2: STARVATION PREVENTION & FAIRNESS");
 $display("==========================================");

 apply_reset();

 check_no_starvation(0, N - 1);

 $display("\n[TC2] Starvation Prevention & Fairness Test Completed.\n");

endtask
