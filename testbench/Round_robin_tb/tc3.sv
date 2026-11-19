task automatic verify_rotation(input int num_rounds = 2);

 logic [N-1:0] expected_gnt;
 logic [N-1:0] check_expected;

 $display("[TC3] Verifying %0d complete round-robin rotations for N=%0d cores...",
          num_rounds, N);

 @(negedge intf.clk_i);
 intf.req_i = '1;

 for (int round = 0; round < num_rounds; round++) begin
   for (int core = 0; core < N; core++) begin

     expected_gnt = (1 << core);
     check_expected = (ERROR_INJECT) ? ~expected_gnt : expected_gnt;

     #1;

     check(intf.gnt_o === check_expected,
           $sformatf("Rotation round %0d: expected core %0d grant (%b), got %b%s",
                     round, core, check_expected, intf.gnt_o,
                     ERROR_INJECT ? " [FAULT INJECTED]" : ""));

     @(negedge intf.clk_i);

   end
 end

 intf.req_i = '0;
 #1;

endtask


task automatic tc3();

 $display("\n==========================================");
 $display(" TESTCASE 3: FULL ROTATION & WRAP-AROUND ");
 $display("==========================================");

 apply_reset();

 verify_rotation(2);

 $display("\n[TC3] Full Rotation & Wrap-Around Test Completed.\n");

endtask