module hello;

  `include "vip/tb_ess.sv"

dummy_dut dut ();

  initial begin
    $display("Hello, World!");
    $finish;
  end

endmodule
