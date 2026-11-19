// TC03 – Write Enable and Write Protection
task automatic tc03_write_protection();
    logic [8-1:0] read_data;
    $display("\n--- TC03: Write Protection ---");
    reset_dut();

    // TODO: Establish a value, disable write enable, attempt overwrite, and read back.
    write_reg(4'd0, 8'd50);
    @(negedge clk_i);
    addr_i  = 4'd0;
    wdata_i = 8'd99;
    wen_i   = 1'b0;
    @(posedge clk_i);
    #1;
    read_reg(4'd0, read_data);
    check(read_data === 8'd50, "Register unchanged while wen_i is LOW");
endtask
