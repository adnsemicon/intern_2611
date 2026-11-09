module tb_final_initial;
  
  `include "vip/tb_ess.sv"

final_initial dut();
 initial begin
   $display("[%0t] Simulation initiated.", $time);
 end
 initial begin
    $display("simulation");
 end
endmodule