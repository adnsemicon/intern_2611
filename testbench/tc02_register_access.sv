// TC02 – Duty-Cycle Register Write/Read Operation
task automatic tc02_register_access();
    logic [8-1:0] read_data;
    $display("\n--- TC02: Register Write/Read ---");
    reset_dut();

    // TODO: Write/read addresses 0 through 7 and the enable register at address 8.
    write_reg(4'd0, 8'd25);
    read_reg(4'd0, read_data);
    check(read_data === 8'd25, "CH0 duty register readback");
endtask
