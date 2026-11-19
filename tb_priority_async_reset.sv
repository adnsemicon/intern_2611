module tb_priority_async_reset;
    localparam int N = 8;
    round_robin_arbiter_if #(.N(N)) arb_if();
    round_robin_arbiter #(.N(N)) dut (
        .clk_i(arb_if.clk_i), .arst_ni(arb_if.arst_ni),
        .req_i(arb_if.req_i), .gnt_o(arb_if.gnt_o)
    );

    task automatic check_initial_priority(input string tag);
        for (int i = 0; i < N; i++) begin
            if (int'(dut.master_order[i]) != i)
                $fatal(1, "%s: order[%0d]=%0d, expected=%0d",
                       tag, i, dut.master_order[i], i);
        end
        if (arb_if.gnt_o !== 8'b00000001)
            $fatal(1, "%s: expected master 0 grant, actual=%b",
                   tag, arb_if.gnt_o);
        $display("PASS %s: default priority and grant to master 0", tag);
    endtask

    initial begin
        arb_if.clk_i = 0;
        arb_if.arst_ni = 1;
        arb_if.req_i = '1;
        #1;
        arb_if.arst_ni = 0;
        #1;
        check_initial_priority("initial async reset");
        arb_if.arst_ni = 1;
        #1;

        // Advance priority three times: master 3 should be next.
        repeat (3) begin
            arb_if.clk_i = 1;
            #1;
            arb_if.clk_i = 0;
            #1;
        end
        if (arb_if.gnt_o !== 8'b00001000)
            $fatal(1, "Setup failed: priority should have advanced to master 3");
        $display("PASS setup: priority advanced to master 3");

        // Assert reset WHILE CLOCK STAYS LOW (no posedge).
        arb_if.arst_ni = 0;
        #1;
        check_initial_priority("mid-operation async reset");

        // Release reset; no positive clock edge occurs here.
        arb_if.arst_ni = 1;
        #1;
        check_initial_priority("after reset release");

        $display("ASYNCHRONOUS RESET PRESERVATION PASSED");
        $finish;
    end
endmodule
