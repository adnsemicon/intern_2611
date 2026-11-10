module unpack;

  // 1024 words of 32-bit memory (RAM model)
  logic [31:0] sram_mem [0:1023];

  // Unpacked array of 8 integers
  int test_scores [8];

  initial
  begin
    sram_mem[0] = 32'h1234_5678;
    sram_mem[1] = 32'h9ABC_DEF0;
    // Whole-array assignment using array literal syntax '{...}
    test_scores = '{100, 95, 88, 92, 79, 85, 90, 94};
    $display("memory 1:0x%08h", sram_mem[0]);
    $display("memory 2:0x%08h", sram_mem[1]);
    $display("string:%p", test_scores);
  end
endmodule

