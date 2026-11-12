module real_sram (
    input  logic              clk,
    input  logic              we,          // Write Enable (1 = write, 0 = read)
    input  logic [9:0]        addr,        // 10-bit address (0 to 1023)
    input  logic [3:0][7:0]   word_data,   // Packed 32-bit input (4 bytes)
    output logic [3:0][7:0]   read_data    // Packed 32-bit output
);

    // Unpacked array: 1024 words of 32-bit memory
    logic [31:0] sram_mem [0:1023];

    // Real hardware uses always_ff instead of initial!
    always_ff @(posedge clk) begin
        if (we)
            sram_mem[addr] <= word_data;   // Write on clock tick
        else
            read_data      <= sram_mem[addr]; // Read on clock tick
    end
endmodule
