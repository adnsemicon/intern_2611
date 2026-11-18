task automatic tc1();
    arst_ni  = 0;
    intf.req = '0;
    #1;
    check(intf.gnt === 4'b0000, "Reset with req=0: gnt must be 0000");

    // Corner case: Active requests while in reset. Arbiter MUST NOT grant during reset!
    intf.req = 4'b1111;
    #1;
    check(intf.gnt === 4'b0000, $sformatf("Reset with req=1111: gnt must be 0000 (got %b)", intf.gnt));

    @(negedge clk_i);
    arst_ni  = 1;
    intf.req = '0;
endtask
