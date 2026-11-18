task automatic tc3();
    apply_reset();
    apply_and_check(4'b0011, 4'b0001, "Two Core Request: Core 0 wins first");
    apply_and_check(4'b0011, 4'b0010, "Two Core Request: Core 1 wins next");
endtask
