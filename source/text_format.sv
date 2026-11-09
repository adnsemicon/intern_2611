`timescale 1ns / 1ps

module text_formatting;

  // 1. Declare the string variable
  string str = "SystemVerilog Formatting";

  // 2. Define a struct and declare the variable for %p printing
  typedef struct {
    bit [7:0] header;
    bit [31:0] payload;
    bit crc_valid;
  } packet_t;
  
  packet_t packet_struct;

  initial begin
    // Initialize the struct fields
    packet_struct.header    = 8'hAB;
    packet_struct.payload   = 32'hDEADBEEF;
    packet_struct.crc_valid = 1'b1;

    // Advance simulation time to demonstrate %t
    #15;

    // 3. Your display statements
    $display("Hex: 0x%0h, Dec: %0d, Bin: %0b, Float: %0.2f", 8'hA5, 8'd25, 4'b1010, 3.14159);
    $display("String: %s, Current Time: %0t, Module Hierarchy: %m", str, $time);
    $display("Pretty Structure Print: %p", packet_struct);
  end

endmodule