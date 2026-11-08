module block_initial;

  `include "vip/tb_ess.sv"

dummy_dut dut();

 initial begin
   $display("[%0t] Simulation initiated.", $time);
 end

endmodule



