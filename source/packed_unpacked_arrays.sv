module packed_unpacked_arrays;
    // 1. PACKED ARRAY (Dimensions on the LEFT)
    logic [3:0][7:0] word_data;

    // 2. UNPACKED ARRAY (Dimensions on the RIGHT)
    logic [31:0] sram_mem [0:1023];   // <--- Here is your exact line!

    initial begin
        // Packed array: 1 continuous 32-bit value
        word_data = 32'hDEAD_BEEF;

        // Unpacked array: 1024 separate memory slots
        sram_mem[0] = 32'h1234_5678;
        sram_mem[1] = word_data;      // Save 0xDEAD_BEEF into slot 1

        // Print results
        $display("Packed Byte 3 : 0x%02h", word_data[3]); // Prints 0xde
        $display("SRAM Slot 0   : 0x%08h", sram_mem[0]);  // Prints 0x12345678
        $display("SRAM Slot 1   : 0x%08h", sram_mem[1]);  // Prints 0xdeadbeef
    end

endmodule

