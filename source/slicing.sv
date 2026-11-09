module slicing;

logic [31:0]data_bus;
int byte_idx = 2;
logic [7:0] current_byte;

assign data_bus = 32'hdeadbeef;
assign current_byte = data_bus[byte_idx*8 +: 8];

initial begin
    $display("Data Bus : 0x%32h", data_bus);
    $display("Sliced byte: 0x%16h", current_byte);
end

endmodule