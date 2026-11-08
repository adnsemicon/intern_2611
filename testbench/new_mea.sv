module new_mea;

  `include "vip/tb_ess.sv"

dummy_dut dut ();

  initial begin
    $display("Meheerin!");
    $finish;
  end

endmodule
