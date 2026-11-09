module tb_text_formatting;
  
  `include "vip/tb_ess.sv"

text_formatting dut();
 initial begin
   $display("[%0t] Simulation initiated.", $time);
 end
 initial begin
    $display("simulation");
 end
 
endmodule