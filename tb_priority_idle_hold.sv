module tb_priority_idle_hold;
    localparam int N = 8;
    round_robin_arbiter_if #(.N(N)) arb_if();
    round_robin_arbiter #(.N(N)) dut (
        .clk_i(arb_if.clk_i), .arst_ni(arb_if.arst_ni),
        .req_i(arb_if.req_i), .gnt_o(arb_if.gnt_o)
    );

    // Expected order after granting master 2 from reset order:
    // [3,4,5,6,7,0,1,2]
    int expected_order [0:N-1] = '{3,4,5,6,7,0,1,2};

    task automatic check_idle(input string tag);
        if (arb_if.gnt_o !== 8'b00000000 || dut.found !== 1'b0)
            $fatal(1, "%s: grant/found should be zero during idle", tag);
        for (int i = 0; i < N; i++) begin
            if (int'(dut.master_order[i]) != expected_order[i])
                $fatal(1, "%s: position %0d changed; actual=%0d expected=%0d",
                       tag, i, dut.master_order[i], expected_order[i]);
        end
        $display("PASS %s: grant=0 and priority table unchanged", tag);
    endtask

    initial begin
        arb_if.clk_i = 0;
        arb_if.arst_ni = 1;
        arb_if.req_i = '0;
        #1;
        arb_if.arst_ni = 0;
        #1;
        arb_if.arst_ni = 1;
        #1;

        // 1) Master 2 wins; one clock rotates the table.
        arb_if.req_i = 8'b00000100;
        #1;
        if (arb_if.gnt_o !== 8'b00000100)
            $fatal(1, "Setup failed: master 2 should win");
        arb_if.clk_i = 1;
        #1;
        arb_if.clk_i = 0;
        #1;

        // 2) No requests. Priority should NOT rotate on any idle clock.
        arb_if.req_i = '0;
        #1;
        check_idle("before idle clocks");
        for (int cycle = 1; cycle <= 5; cycle++) begin
            arb_if.clk_i = 1;
            #1;
            arb_if.clk_i = 0;
            #1;
            check_idle($sformatf("after idle clock %0d", cycle));
        end

        // 3) With all masters active, preserved top priority = master 3.
        arb_if.req_i = '1;
        #1;
        if (arb_if.gnt_o !== 8'b00001000)
            $fatal(1, "Priority not preserved: expected grant to master 3");
        $display("PASS final probe: master 3 still highest priority");
        $display("IDLE PRIORITY PRESERVATION PASSED");
        $finish;
    end
endmodule
