module tb_priority_selection;
    localparam int N = 8;
    round_robin_arbiter_if #(.N(N)) arb_if();

    // Method 1: connect individual DUT ports to interface signals.
    round_robin_arbiter #(.N(N)) dut (
        .clk_i   (arb_if.clk_i),
        .arst_ni (arb_if.arst_ni),
        .req_i   (arb_if.req_i),
        .gnt_o   (arb_if.gnt_o)
    );

    int checks = 0;

    task automatic check_selection(
        input string name,
        input logic [N-1:0] requests,
        input logic [N-1:0] expected_grant,
        input logic expected_found,
        input int expected_position
    );
        arb_if.req_i = requests;
        #1;  // combinational settling; NO clock edge
        checks++;
        if (arb_if.gnt_o !== expected_grant ||
            dut.found !== expected_found ||
            int'(dut.gnt_idx) != expected_position) begin
            $display("FAIL %s req=%b grant=%b expected=%b found=%b pos=%0d",
                     name, requests, arb_if.gnt_o, expected_grant,
                     dut.found, dut.gnt_idx);
            $fatal(1, "Priority selection mismatch");
        end
        $display("PASS %-27s req=%b grant=%b pos=%0d",
                 name, requests, arb_if.gnt_o, dut.gnt_idx);
    endtask

    initial begin
        arb_if.clk_i   = 1'b0;
        arb_if.arst_ni = 1'b1;
        arb_if.req_i   = '0;
        #1;
        arb_if.arst_ni = 1'b0; // real falling edge triggers async reset
        #1;
        arb_if.arst_ni = 1'b1;
        #1;

        // Reset order: [0,1,2,3,4,5,6,7]
        check_selection("No request",       8'b00000000, 8'b00000000, 0, 0);
        check_selection("Only master 5",    8'b00100000, 8'b00100000, 1, 5);
        check_selection("Masters 2 and 5",  8'b00100100, 8'b00000100, 1, 2);
        check_selection("Masters 0 and 7",  8'b10000001, 8'b00000001, 1, 0);
        check_selection("All request",      8'b11111111, 8'b00000001, 1, 0);

        // Set priority to [6,7,0,1,2,3,4,5].
        // Give only master 5 a request and then one clock rising edge.
        arb_if.req_i = 8'b00100000;
        #1;
        arb_if.clk_i = 1'b1;
        #1; // wait for nonblocking assignment and combinational settle
        arb_if.clk_i = 1'b0;
        #1;

        // Selection must follow rotated priority order, NOT fixed index order.
        check_selection("Rotated: all",      8'b11111111, 8'b01000000, 1, 0);
        check_selection("Rotated: 0 and 7",  8'b10000001, 8'b10000000, 1, 1);
        check_selection("Rotated: 2 and 5",  8'b00100100, 8'b00000100, 1, 4);
        check_selection("Rotated: 5 only",   8'b00100000, 8'b00100000, 1, 7);
        check_selection("Rotated: idle",     8'b00000000, 8'b00000000, 0, 0);

        $display("PRIORITY SELECTION PASSED: %0d checks", checks);
        $finish;
    end
endmodule
