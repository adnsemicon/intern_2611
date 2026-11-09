module pack_unpack;
 logic [7:0] byte_data;
 logic [3:0][7:0] word_data;

  initial begin
    word_data = 32'hDEAD_BEEF;
    $display("Entire Word : 0x%08h", word_data);        // 0xdeadbeef
    $display("Byte Index 3: 0x%02h", word_data[3]);     // 0xde
    $display("Byte Index 0: 0x%02h", word_data[0]);     // 0xef
    $display("Bit Slice   : 0x%01h", word_data[3][7:4]); // 0xd
 end

endmodule