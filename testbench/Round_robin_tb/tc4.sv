task automatic tc4();
    apply_reset();
    apply_and_check(4'b1111, 4'b0001, "All Core Request: Core 0 wins");
    apply_and_check(4'b1111, 4'b0010, "All Core Request: Core 1 wins");
    apply_and_check(4'b1111, 4'b0100, "All Core Request: Core 2 wins");
    apply_and_check(4'b1111, 4'b1000, "All Core Request: Core 3 wins");
    apply_and_check(4'b1111, 4'b0001, "All Core Request: Core 0 wins again (wrap)");
endtask
