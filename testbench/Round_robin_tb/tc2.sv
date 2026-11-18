task automatic tc2();
    apply_reset();
    apply_and_check(4'b0100, 4'b0100, "Core 2 Request Grant");
endtask
